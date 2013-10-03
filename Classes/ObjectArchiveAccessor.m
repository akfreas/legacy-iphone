#import "Person.h"
#import "Event.h"
#import "EventPersonRelation.h"
#import "Figure.h"
#import "ObjectArchiveAccessor.h"
#import "Utility_AppSettings.h"
#import "MainScreen.h"

@interface ObjectArchiveAccessor ()

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation ObjectArchiveAccessor {
    
    NSURL *archiveUrl;
    NSPersistentStoreCoordinator *storeCoordinator;
    NSOperationQueue *operationQueue;
}

static NSString *DbName = @"Legacy.sqlite";
static NSString *PersonEntityName = @"Person";

+(ObjectArchiveAccessor *)sharedInstance {
    static ObjectArchiveAccessor *instance;
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[ObjectArchiveAccessor alloc] init];
        });
    }
    return instance;
}



-(id)init {
    self = [super init];
    
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

-(void)managedObjectContextDidSave:(NSNotification *)notif {
    if (notif.object != self.managedObjectContext) {
        if ([NSThread isMainThread] == NO) {
            [self performSelectorOnMainThread:@selector(managedObjectContextDidSave:) withObject:notif waitUntilDone:YES];
            return;
        }
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notif];
    }
}

#pragma mark Core Data Utility Functions

-(NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext == nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _managedObjectContext;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    NSError *error;
    if (storeCoordinator != nil) {
        return storeCoordinator;
    } else {
        NSURL *dbPath = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:DbName]];
        storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbPath options:nil error:&error];
    }
    
    if (error == nil) {
        return storeCoordinator;
    } else {
        NSLog(@"Error loading persistent store coordinator: %@", error);
        return nil;
    }
}

-(NSManagedObjectModel *)managedObjectModel {
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:nil];
    return mom;
}

- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(void)save {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        NSError *error;
        if([self.managedObjectContext hasChanges]) {
            [self.managedObjectContext save:&error];
        }
    });
}

#pragma mark Getter Methods

-(Person *)primaryPerson {

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:PersonEntityName];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isPrimary == YES"];
    NSError *error;
    Person *primaryPerson;
    fetchRequest.predicate = pred;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] == 1 && error == NULL) {
        primaryPerson = [results objectAtIndex:0];
    } else {
        primaryPerson = nil;
    }
    return primaryPerson;
}


-(NSArray *)allPersons {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PersonEntityName];
    NSPredicate *fbUsersPred = [NSPredicate predicateWithFormat:@"isFacebookUser == %@", [NSNumber numberWithBool:YES]];
    request.predicate = fbUsersPred;
    
    NSSortDescriptor *sortDescriptorForBirthday = [NSSortDescriptor sortDescriptorWithKey:@"birthday" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptorForBirthday];
    
    NSError *error;
    NSArray *allPersons;
    allPersons = [self.managedObjectContext executeFetchRequest:request error:&error];
    return allPersons;
}

-(NSArray *)addedPeople {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PersonEntityName];
    NSPredicate *fbUsersPred = [NSPredicate predicateWithFormat:@"(isFacebookUser == %@) AND (isPrimary <> YES)", [NSNumber numberWithBool:YES]];
    //    NSPredicate *fbUsersPred = [NSPredicate predicateWithFormat:@"isFacebookUser == %@", [NSNumber numberWithBool:YES]];
    
    request.predicate = fbUsersPred;
    
    NSSortDescriptor *sortDescriptorForBirthday = [NSSortDescriptor sortDescriptorWithKey:@"birthday" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptorForBirthday];
    
    NSError *error;
    NSArray *allPersons;
    allPersons = [self.managedObjectContext executeFetchRequest:request error:&error];
    return allPersons;
    
}

-(NSArray *)allFigures {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Figure"];
    NSError *error;
    NSArray *allFigures = [self.managedObjectContext executeFetchRequest:request error:&error];
    return allFigures;
}


-(NSArray *)eventsForFigure:(Figure *)figure {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"figure.id == %@", figure.id];
    NSSortDescriptor *ageYearSorter = [NSSortDescriptor sortDescriptorWithKey:@"ageYears" ascending:YES];
    NSSortDescriptor *ageMonthSorter = [NSSortDescriptor sortDescriptorWithKey:@"ageMonths" ascending:YES];
    NSSortDescriptor *ageDaySorter = [NSSortDescriptor sortDescriptorWithKey:@"ageDays" ascending:YES];
    
    request.sortDescriptors = @[ageYearSorter, ageMonthSorter, ageDaySorter];
    request.predicate = predicate;
    NSError *error;
    NSArray *events = [self.managedObjectContext executeFetchRequest:request error:&error];
    return events;
}

-(void)getOrCreatePersonWithFacebookGraphUser:(id<FBGraphUser>)facebookUser completionBlock:(void(^)(Person *thePerson))completionBlock {
    
    Person *thePerson = [self personWithFacebookId:facebookUser.id];
    
    if (thePerson == nil) {
        thePerson = [self addPersonWithFacebookUser:facebookUser completionBlock:completionBlock];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(thePerson);
        });
    }
}


-(Person *)personWithFacebookId:(NSString *)facebookId {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:PersonEntityName];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookId];
    fetchRequest.predicate = pred;
    NSError *error;
    
    NSArray *userArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    Person *fetchedPerson;
    if ([userArray count] == 1) {
        fetchedPerson = [userArray objectAtIndex:0];
    } else {
        fetchedPerson = nil;
    }
    return fetchedPerson;
}


#pragma mark Setter Methods

-(void)setPrimaryPerson:(Person *)user {
    
    Person *currentPrimaryUser = [self primaryPerson];
    currentPrimaryUser.isPrimary = [NSNumber numberWithBool:NO];
    user.isPrimary = [NSNumber numberWithBool:YES];
    [self save];
}



-(void)createAndSetPrimaryUser:(id<FBGraphUser>)fbUser completionBlock:(void(^)(Person *thePerson))completionBlock {
    
    if ([self.primaryPerson.facebookId isEqualToString:fbUser.id] == NO) {
        __block Person *personFromFb = [self personWithFacebookId:fbUser.id];
        if (personFromFb == nil) {
            
            NSEntityDescription *desc = [NSEntityDescription entityForName:PersonEntityName inManagedObjectContext:[self managedObjectContext]];
            personFromFb = [[Person alloc] initWithEntity:desc insertIntoManagedObjectContext:self.managedObjectContext];
            
            personFromFb.facebookId = fbUser.id;
            personFromFb.firstName = fbUser.first_name;
            personFromFb.lastName = fbUser.last_name;
            personFromFb.isFacebookUser = [NSNumber numberWithBool:YES];
            [self setPrimaryPerson:personFromFb];
            
            NSLog(@"Active session: %@", [FBSession activeSession]);
            FBRequest *request = [FBRequest requestForGraphPath:@"me?fields=id,first_name,last_name,birthday,picture"];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, FBGraphObject *result, NSError *error) {
                NSLog(@"Result: %@ error: %@", result , error);
                NSString *birthdayString = result[@"birthday"];
                
                NSDate *theBirthday = [[Utility_AppSettings dateFormatterForDisplay] dateFromString:birthdayString];
                if (theBirthday == nil) {
                    theBirthday = [[Utility_AppSettings dateFormatterForPartialBirthday] dateFromString:birthdayString];
                    personFromFb.birthday = theBirthday;
                    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForNoBirthdayNotification object:nil userInfo:@{KeyForPersonInBirthdayNotFoundNotification : personFromFb}];
                } else {
                    personFromFb.birthday = theBirthday;
                }
                
                
                
                NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=140", personFromFb.facebookId];
                
                NSMutableURLRequest *profilePicRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
                [NSURLConnection sendAsynchronousRequest:profilePicRequest queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        personFromFb.thumbnail = data;
                        [self save];
                        completionBlock(personFromFb);
                    });
                }];
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(personFromFb);
            });
        }
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(self.primaryPerson);
        });
    }
}

-(void)clearEventsAndFiguresAndSave {
    
//    NSFetchRequest *eventDeleteFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSError *error;
//    NSArray *arrayOfEvents = [self.managedObjectContext executeFetchRequest:eventDeleteFetchRequest error:&error];
//    
//    for (Event *event in arrayOfEvents) {
//        [self.managedObjectContext deleteObject:event];
//    }
//    
//    NSFetchRequest *figureDeleteFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Figure"];
//    
//    NSArray *arrayOfFigures = [self.managedObjectContext executeFetchRequest:figureDeleteFetchRequest error:&error];
//    
//    for (Figure *figure in arrayOfFigures) {
//        [self.managedObjectContext deleteObject:figure];
//    }
    
    NSFetchRequest *relationDeleteFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"EventPersonRelation"];
    
    NSArray *arrayOfRelations = [self.managedObjectContext executeFetchRequest:relationDeleteFetchRequest error:&error];
    
    for (EventPersonRelation *relation in arrayOfRelations) {
        [self.managedObjectContext deleteObject:relation];
    }
}

-(Event *)addEventWithJson:(NSDictionary *)json {
    NSEntityDescription *eventEntityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[self managedObjectContext]];
    
    Event *newEvent = [[Event alloc] initWithEntity:eventEntityDesc insertIntoManagedObjectContext:[self managedObjectContext]];
    
    
    newEvent.eventDescription = json[@"event_description"];
    newEvent.ageYears = [NSNumber numberWithInt:[json[@"age_years"] intValue]];
    newEvent.ageMonths = [NSNumber numberWithInt:[json[@"age_months"] intValue]];
    newEvent.ageDays = [NSNumber numberWithInt:[json[@"age_days"] intValue]];
    newEvent.eventId = [NSNumber numberWithInt:[json[@"event_id"] intValue]];
    
    return newEvent;
}

-(Figure *)addFigureWithJson:(NSDictionary *)json {
    
    NSNumber *figureId = [NSNumber numberWithInt:[json[@"id"] intValue]];
    Figure *eventFigure = [self fetchFigureWithId:figureId];
    
    if (eventFigure == nil) {
        
        NSEntityDescription *figureEntityDesc = [NSEntityDescription entityForName:@"Figure" inManagedObjectContext:[self managedObjectContext]];
        eventFigure = [[Figure alloc] initWithEntity:figureEntityDesc insertIntoManagedObjectContext:[self managedObjectContext]];
        
        eventFigure.name = json[@"name"];
        eventFigure.imageURL = json[@"image_url"];
        eventFigure.id = json[@"id"];
        
    }
    
    return eventFigure;
}

-(void)addEventAndFigureWithJson:(NSDictionary *)json {
    NSString *eventId = json[@"event_id"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"eventId == %@", eventId];
    NSError *error;
    NSArray *events =  [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    Event *newEvent;
    if ([events count] < 1) {
        
        newEvent = [self addEventWithJson:json];
        
    } else {
        newEvent = [events lastObject];
    }
    NSDictionary *figureJson = json[@"figure"];
    NSFetchRequest *eventFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Figure"];
    eventFetchRequest.predicate = [NSPredicate predicateWithFormat:@"id == %@", figureJson[@"id"]];
    NSArray *figures = [self.managedObjectContext executeFetchRequest:eventFetchRequest error:&error];
    
    Figure *assocFigure;
    
    if ([figures count] > 0) {
        assocFigure = [figures lastObject];
    } else {
        assocFigure = [self addFigureWithJson:figureJson];
    }
    
    newEvent.figure = assocFigure;
    [self save];
}

-(Person *)personWithJson:(NSDictionary *)json {
    __block Person *person = [self personWithFacebookId:json[@"facebook_id"]];
    
    if (person == nil && json != nil) {
        NSEntityDescription *personEntityDesc = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
        person = [[Person alloc] initWithEntity:personEntityDesc insertIntoManagedObjectContext:self.managedObjectContext];
        person.facebookId = json[@"facebook_id"];
        person.firstName = json[@"first_name"];
        person.lastName = json[@"last_name"];
        person.birthday = [[Utility_AppSettings dateFormatterForRequest] dateFromString:json[@"birthday"]];
        person.isFacebookUser = [NSNumber numberWithBool:YES];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:json[@"profile_pic"]]];
    [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *imageData, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                person.thumbnail = imageData;
                [self save];
            });
        }
    }];
    return person;
}

-(void)addEventAndFigureRelationWithJson:(NSDictionary *)json {
    
    NSString *jsonError = json[@"error"];
    
    
    NSEntityDescription *relationEntityDesc = [NSEntityDescription entityForName:@"EventPersonRelation" inManagedObjectContext:self.managedObjectContext];
    EventPersonRelation *relation = [[EventPersonRelation alloc] initWithEntity:relationEntityDesc insertIntoManagedObjectContext:self.managedObjectContext];
    
    Event *newEvent;

    if (jsonError == nil) {
        NSString *eventId = json[@"event_id"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"eventId == %@", eventId];
        NSError *error;
        NSArray *events = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if ([events count] < 1) {
            
            newEvent = [self addEventWithJson:json];
            
        } else if (eventId != nil) {
            newEvent = [events lastObject];
        }
        NSDictionary *figureJson = json[@"figure"];
        NSFetchRequest *eventFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Figure"];
        eventFetchRequest.predicate = [NSPredicate predicateWithFormat:@"id == %@", figureJson[@"id"]];
        NSArray *figures = [self.managedObjectContext executeFetchRequest:eventFetchRequest error:&error];
        
        Figure *assocFigure;
        
        if ([figures count] > 0) {
            assocFigure = [figures lastObject];
        } else {
            assocFigure = [self addFigureWithJson:figureJson];
        }
        
        newEvent.figure = assocFigure;
        relation.event = newEvent;
    }
    
    
    NSDictionary *personDict = json[@"person"];
    Person *assocPerson;
    if (personDict != nil) {
        assocPerson = [self personWithJson:personDict];
    }
    
    
    relation.person = assocPerson;
    if (newEvent == nil) {
        relation.pinsToTop = [NSNumber numberWithBool:YES];
    } else  {
        relation.pinsToTop = [NSNumber numberWithBool:NO];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self save];
    });
}

-(Figure *)fetchFigureWithId:(NSNumber *)figureId {
    
    NSFetchRequest *figureFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Figure"];
    
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"id == %@", figureId];
    
    figureFetchRequest.predicate = fetchPredicate;
    NSError *error;
    NSArray *fetchedArray = [self.managedObjectContext executeFetchRequest:figureFetchRequest error:&error];
    
    Figure *returnFigure;
    if (fetchedArray != nil) {
        returnFigure = [fetchedArray lastObject];
    } else {
        returnFigure = nil;
    }
    return returnFigure;
}

-(NSArray *)eventRelationSortDescriptors {
    
    NSSortDescriptor *nilSorter = [NSSortDescriptor sortDescriptorWithKey:@"pinsToTop" ascending:NO];
    NSSortDescriptor *meSorter = [NSSortDescriptor sortDescriptorWithKey:@"person.isPrimary" ascending:NO];
    NSSortDescriptor *friendSorter = [NSSortDescriptor sortDescriptorWithKey:@"person.isFacebookUser" ascending:NO];
    NSSortDescriptor *bdaySorter = [NSSortDescriptor sortDescriptorWithKey:@"person.birthday" ascending:NO];
    
    NSSortDescriptor *ageYearSorter = [NSSortDescriptor sortDescriptorWithKey:@"event.ageYears" ascending:YES];
    NSSortDescriptor *ageMonthSorter = [NSSortDescriptor sortDescriptorWithKey:@"event.ageMonths" ascending:YES];
    NSSortDescriptor *ageDaySorter = [NSSortDescriptor sortDescriptorWithKey:@"event.ageDays" ascending:YES];
    
    return @[nilSorter, meSorter, friendSorter, bdaySorter, ageYearSorter, ageMonthSorter, ageDaySorter];
}


-(Person *)addPersonWithFacebookUser:(id<FBGraphUser>)fbUser completionBlock:(void(^)(Person *thePerson))completionBlock {
    
    NSEntityDescription *desc = [NSEntityDescription entityForName:PersonEntityName inManagedObjectContext:[self managedObjectContext]];
    __block Person *newPerson = [[Person alloc] initWithEntity:desc insertIntoManagedObjectContext:self.managedObjectContext];
    
    newPerson.facebookId = fbUser.id;
    newPerson.isFacebookUser = [NSNumber numberWithBool:YES];
    newPerson.isPrimary = [NSNumber numberWithBool:NO];
    newPerson.firstName = fbUser.first_name;
    newPerson.lastName = fbUser.last_name;
    
    FBRequest *request = [FBRequest requestForGraphPath:[NSString stringWithFormat:@"me/friends/%@?fields=birthday,picture", fbUser.id]];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, FBGraphObject *result, NSError *error) {
        NSLog(@"Result: %@ error: %@", result[@"data"] , error);
        NSArray *resultArray = result[@"data"];
        if ([resultArray count] == 1) {
            NSString *birthdayString = resultArray[0][@"birthday"];
            
            
            NSDate *theBirthday = [[Utility_AppSettings dateFormatterForDisplay] dateFromString:birthdayString];
            
            if (theBirthday == nil) {
                theBirthday = [[Utility_AppSettings dateFormatterForPartialBirthday] dateFromString:birthdayString];
                newPerson.birthday = theBirthday;
                [[MainScreen sharedInstance] showAlertForNoBirthday:newPerson completion:^(Person *person) {
                    [self save];
                    completionBlock(newPerson);
                } cancellation:^(Person *person) {
                    [self removePerson:person];
                    [self save];
                    completionBlock(nil);
                }];
            } else {
                newPerson.birthday = theBirthday;
                completionBlock(newPerson);
            }
            
            NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=140", fbUser.id];
            
            NSMutableURLRequest *profilePicRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
            [NSURLConnection sendAsynchronousRequest:profilePicRequest queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    newPerson.thumbnail = data;
                    [self save];
                });
            }];
        }
    }];
    return newPerson;
}

-(void)addFacebookUsers:(NSArray *)users completionBlock:(void(^)())completionBlock {
    
    __block NSInteger userCount = [users count];
    for (id user in users) {
        if ([user conformsToProtocol:@protocol(FBGraphUser)]) {
            id<FBGraphUser> fbUser = user;
            [self getOrCreatePersonWithFacebookGraphUser:fbUser completionBlock:completionBlock];
        }
    }
}

-(void)removePerson:(Person *)user {
    
    [self.managedObjectContext deleteObject:user];
    [self save];
}

-(NSFetchedResultsController *)fetchedResultsControllerForRelations {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventPersonRelation"];
    fetchRequest.sortDescriptors = [self eventRelationSortDescriptors];
    
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"pinsToTop" cacheName:nil];
    return resultsController;
}

@end
