#import "Person.h"
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
}

static NSString *DbName = @"Yardstick.sqlite";
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
    NSError *error;
    NSArray *allPersons;
    allPersons = [self.managedObjectContext executeFetchRequest:request error:&error];
    return allPersons;
}

-(Person *)getOrCreatePersonWithFacebookGraphUser:(id<FBGraphUser>)facebookUser {
    
    Person *theUser = [self personWithFacebookId:facebookUser.id];
    
    if (theUser == nil) {
        theUser = [self addPersonWithFacebookUser:facebookUser];
    }
    return theUser;
}

-(Person *)personWithFacebookId:(NSString *)facebookId {
    
    NSNumber *facebookIdNum = [NSNumber numberWithInteger:[facebookId integerValue]];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:PersonEntityName];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookIdNum];
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

-(Person *)addPersonWithFacebookUser:(id<FBGraphUser>)fbUser {
    
    NSEntityDescription *desc = [NSEntityDescription entityForName:PersonEntityName inManagedObjectContext:[self managedObjectContext]];
    __block Person *newPerson = [[Person alloc] initWithEntity:desc insertIntoManagedObjectContext:self.managedObjectContext];
    Person *primaryPerson = [self primaryPerson];
    FBRequest *request = [FBRequest requestForGraphPath:[NSString stringWithFormat:@"me/friends/%@?fields=birthday", fbUser.id]];
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
                [self save];
            }
        }
    }];
    newPerson.facebookId = [NSNumber numberWithInt: [fbUser.id integerValue]];
    newPerson.firstName = fbUser.first_name;
    newPerson.lastName = fbUser.last_name;
    [self save];
    return newPerson;
}

-(void)addFacebookUsers:(NSArray *)users {
    
    for (id user in users) {
        if ([user conformsToProtocol:@protocol(FBGraphUser)]) {
            id<FBGraphUser> fbUser = user;
            [self getOrCreatePersonWithFacebookGraphUser:fbUser];
        }
    }
}

-(void)removePerson:(Person *)user {
    
    Person *userInArray = [self personWithFacebookId:[user.facebookId stringValue]];
    [self.managedObjectContext deleteObject:userInArray];
    [self save];
}
    
@end
