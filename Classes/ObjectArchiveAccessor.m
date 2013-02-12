#import "YardstickPerson.h"
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

static NSString *archiveStringURL = @"atYourAgeArchive.plist";
static NSString *DbName = @"Yardstick.sqlite";
static NSString *KeyForUserArray = @"UserArray";
static NSString *KeyForPrimaryUserId = @"PrimaryUserId";
static NSString *FriendEntityName = @"Friend";

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


        NSLog(@"Archive url: %@", [archiveUrl path]);
        [self loadOrCreateArchiveDict];
    }
    return self;
}

#pragma mark Core Data Utility Functions

-(NSManagedObjectContext *)managedObjectContext {
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return context;
}

-(NSPersistentStoreCoordinator *)storeCoordinator {
    
    NSError *error;
    if (storeCoordinator != nil) {
        return storeCoordinator;
    } else {
        NSURL *dbPath = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:DbName]];
        storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbPath options:nil error:&error];
    }
    
    if (error != nil) {
        return storeCoordinator;
    } else {
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


-(YardstickPerson *)primaryUser {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:FriendEntityName];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"primaryUser == YES"];
    NSError *error;
    YardstickPerson *primaryUser;
    fetchRequest.predicate = pred;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] == 1 && error == NULL) {
        primaryUser = [results objectAtIndex:0];
    } else {
        primaryUser = nil;
    }
    return primaryUser;
}

#pragma mark Getter Methods

-(NSArray *)allUsers {
        
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:FriendEntityName];
    NSError *error;
    NSArray *allUsers;
    allUsers = [self.managedObjectContext executeFetchRequest:request error:&error];
    return allUsers;
}

-(YardstickPerson *)getOrCreateUserWithFacebookGraphPerson:(id<FBGraphUser>)facebookUser {
    
    YardstickPerson *theUser = [self userWithFacebookId:facebookUser.id];
    
    if (theUser == nil) {
        theUser = [self addFacebookPerson:facebookUser];
    }
    return theUser;
}

-(YardstickPerson *)userWithFacebookId:(NSString *)facebookId {
    
    NSNumber *facebookIdNum = [NSNumber numberWithInteger:[facebookId integerValue]];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:FriendEntityName];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookIdNum];
    fetchRequest.predicate = pred;
    NSError *error;
    
    NSArray *userArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    YardstickPerson *fetchedUser;
    if ([userArray count] == 1) {
        fetchedUser = [userArray objectAtIndex:0];
    } else {
        fetchedUser = nil;
    }
    
}


#pragma mark Setter Methods

-(void)setPrimaryPerson:(YardstickPerson *)user error:(NSError **)error {
    
    YardstickPerson *currentPrimaryUser = [self primaryUser];
    currentPrimaryUser.isPrimary = [NSNumber numberWithBool:NO];
    user.isPrimary = [NSNumber numberWithBool:YES];
    [self save];
}

-(void)addPerson:(YardstickPerson *)user {
    [self.managedObjectContext insertObject:user];
    [self save];
}

-(YardstickPerson *)addFacebookPerson:(id<FBGraphUser>)fbUser {
    
    NSEntityDescription *desc = [NSEntityDescription entityForName:FriendEntityName inManagedObjectContext:[self managedObjectContext]];
    YardstickPerson *newUser = [[YardstickPerson alloc] initWithEntity:desc insertIntoManagedObjectContext:self.managedObjectContext];
    newUser.firstName = fbUser.first_name;
    newUser.lastName = fbUser.last_name;
    newUser.birthday = [[Utility_AppSettings dateFormatterForDisplay] dateFromString:fbUser.birthday];
    newUser.facebookId = [NSNumber numberWithInt: [fbUser.id integerValue]];
    [self save];
    return newUser;
}

-(void)addFacebookUsers:(NSArray *)users {
    
    for (id user in users) {
        if ([user conformsToProtocol:@protocol(FBGraphUser)]) {
            id<FBGraphUser> fbUser = user;
            [self getOrCreateUserWithFacebookGraphPerson:fbUser];
        }
    }
}

-(void)removePerson:(YardstickPerson *)user {
    
    YardstickPerson *userInArray = [self userWithFacebookId:[user.facebookId stringValue]];
    [self.managedObjectContext deleteObject:userInArray];
}
    
@end
