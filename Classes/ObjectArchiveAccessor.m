#import "Person.h"
#import "Event.h"
#import "EventPersonRelation.h"
#import "Figure.h"
#import "ObjectArchiveAccessor.h"
#import "Utility_AppSettings.h"

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

static NSString *DbName = @"AtYourAge.sqlite";
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
    }
    return self;
}

#pragma mark Core Data Utility Functions

-(NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext == nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
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
    NSError *error;
    [self.managedObjectContext save:&error];
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

-(void)addPerson:(Person *)user {
    [self.managedObjectContext insertObject:user];
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
                        completionBlock(personFromFb);
                        [self save];
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
    
    NSFetchRequest *eventDeleteFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSError *error;
    NSArray *arrayOfEvents = [self.managedObjectContext executeFetchRequest:eventDeleteFetchRequest error:&error];
    
    for (Event *event in arrayOfEvents) {
        [self.managedObjectContext deleteObject:event];
    }
    
    NSFetchRequest *figureDeleteFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Figure"];
    
    NSArray *arrayOfFigures = [self.managedObjectContext executeFetchRequest:figureDeleteFetchRequest error:&error];
    
    for (Figure *figure in arrayOfFigures) {
        [self.managedObjectContext deleteObject:figure];
    }
    
    NSFetchRequest *relationDeleteFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"EventPersonRelation"];
    
    NSArray *arrayOfRelations = [self.managedObjectContext executeFetchRequest:relationDeleteFetchRequest error:&error];
    
    for (EventPersonRelation *relation in arrayOfRelations) {
        [self.managedObjectContext deleteObject:relation];
    }
    
    [self save];
}

-(void)addEventAndFigureWithJson:(NSDictionary *)json {
    
    NSEntityDescription *eventEntityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[self managedObjectContext]];
    
    
    Event *newEvent = [[Event alloc] initWithEntity:eventEntityDesc insertIntoManagedObjectContext:[self managedObjectContext]];
    
    
    
    newEvent.eventDescription = json[@"event_description"];
    newEvent.ageYears = [NSNumber numberWithInt:[json[@"age_years"] intValue]];
    newEvent.ageMonths = [NSNumber numberWithInt:[json[@"age_months"] intValue]];
    newEvent.ageDays = [NSNumber numberWithInt:[json[@"age_days"] intValue]];
    newEvent.eventId = [NSNumber numberWithInt:[json[@"event_id"] intValue]];
    
    
    NSDictionary *figureDict = json[@"figure"];
    NSNumber *figureId = [NSNumber numberWithInt:[figureDict[@"id"] intValue]];
    
    Figure *eventFigure = [self fetchFigureWithId:figureId];
    
    if (eventFigure == nil) {
        
        NSEntityDescription *figureEntityDesc = [NSEntityDescription entityForName:@"Figure" inManagedObjectContext:[self managedObjectContext]];
        eventFigure = [[Figure alloc] initWithEntity:figureEntityDesc insertIntoManagedObjectContext:[self managedObjectContext]];
        
        eventFigure.name = figureDict[@"name"];
        eventFigure.imageURL = figureDict[@"image_url"];
    }
    
    newEvent.figure = eventFigure;
    
    NSDictionary *personDict = json[@"person"];
    __block Person *assocPerson = [self personWithFacebookId:personDict[@"facebook_id"]];
    
    if (assocPerson == nil && personDict != nil) {
        NSEntityDescription *personEntityDesc = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
        assocPerson = [[Person alloc] initWithEntity:personEntityDesc insertIntoManagedObjectContext:self.managedObjectContext];
        assocPerson.facebookId = personDict[@"facebook_id"];
        assocPerson.firstName = personDict[@"first_name"];
        assocPerson.lastName = personDict[@"last_name"];
        assocPerson.birthday = [[Utility_AppSettings dateFormatterForRequest] dateFromString:personDict[@"birthday"]];
        assocPerson.isFacebookUser = [NSNumber numberWithBool:YES];
        [self save];
        
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:personDict[@"profile_pic"]]];
        
        
        [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *imageData, NSError *error) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                assocPerson.thumbnail = imageData;
                [self save];
            }
        }];
    }
    
    
    NSEntityDescription *relationEntityDesc = [NSEntityDescription entityForName:@"EventPersonRelation"  inManagedObjectContext:self.managedObjectContext];
    EventPersonRelation *relation = [[EventPersonRelation alloc] initWithEntity:relationEntityDesc insertIntoManagedObjectContext:self.managedObjectContext];
    
    relation.event = newEvent;
    relation.person = assocPerson;
    
    
    
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

-(NSArray *)getStoredEvents {
 
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSError *error;
    NSArray *events = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return events;
}

-(NSArray *)getStoredEventRelations {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"EventPersonRelation"];
    NSSortDescriptor *meSorter = [NSSortDescriptor sortDescriptorWithKey:@"person.isPrimary" ascending:NO];
    NSSortDescriptor *friendSorter = [NSSortDescriptor sortDescriptorWithKey:@"person.isFacebookUser" ascending:NO];
    request.sortDescriptors = @[meSorter, friendSorter];
    NSError *error;
    NSArray *events = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return events;
}

-(Person *)addPersonWithFacebookUser:(id<FBGraphUser>)fbUser completionBlock:(void(^)(Person *thePerson))completionBlock {
    
    NSEntityDescription *desc = [NSEntityDescription entityForName:PersonEntityName inManagedObjectContext:[self managedObjectContext]];
    __block Person *newPerson = [[Person alloc] initWithEntity:desc insertIntoManagedObjectContext:self.managedObjectContext];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:KeyForNoBirthdayNotification object:nil userInfo:@{KeyForPersonInBirthdayNotFoundNotification : newPerson}];
            } else {
                newPerson.birthday = theBirthday;
            }
            
            NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=140", fbUser.id];
            
            NSMutableURLRequest *profilePicRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
       [NSURLConnection sendAsynchronousRequest:profilePicRequest queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    newPerson.thumbnail = data;
                    completionBlock(newPerson);
                    [self save];
                });
            }];
        }
    }];
    newPerson.facebookId = fbUser.id;
    newPerson.isFacebookUser = [NSNumber numberWithBool:YES];
    newPerson.isPrimary = [NSNumber numberWithBool:NO];
    newPerson.firstName = fbUser.first_name;
    newPerson.lastName = fbUser.last_name;
    [self save];
    return newPerson;
}

-(void)addFacebookUsers:(NSArray *)users completionBlock:(void(^)())completionBlock {
    
    for (id user in users) {
        if ([user conformsToProtocol:@protocol(FBGraphUser)]) {
            id<FBGraphUser> fbUser = user;
            [self getOrCreatePersonWithFacebookGraphUser:fbUser completionBlock:completionBlock];
        }
    }
}

-(void)removePerson:(Person *)user {
    
    Person *userInArray = [self personWithFacebookId:user.facebookId];
    [self.managedObjectContext deleteObject:userInArray];
    [self save];
}

-(NSFetchedResultsController *)fetchedResultsControllerForPeople {
    
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:PersonEntityName];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"birthday" ascending:YES];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    return resultsController;
}

@end
