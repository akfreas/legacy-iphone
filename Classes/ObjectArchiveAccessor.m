#import "User.h"
#import "ObjectArchiveAccessor.h"
#import "Utility_AppSettings.h"

@implementation ObjectArchiveAccessor {
    
    NSURL *archiveUrl;
    NSMutableDictionary *archiveDict;
}

static NSString *archiveStringURL = @"atYourAgeArchive.plist";
static NSString *KeyForUserArray = @"UserArray";
static NSString *KeyForPrimaryUserId = @"PrimaryUserId";

-(id)init {
    self = [super init];
    
    if (self) {
        NSError *error;
        NSURL *documentDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
        archiveUrl = [NSURL URLWithString:archiveStringURL relativeToURL:documentDir];
        NSLog(@"Archive url: %@", [archiveUrl path]);
        [self loadOrCreateArchiveDict];
    }
    return self;
}

-(void)loadOrCreateArchiveDict {
    archiveDict = nil;
    archiveDict = [NSKeyedUnarchiver unarchiveObjectWithFile:[archiveUrl path]];
    
    if (archiveDict == nil) {
        archiveDict = [NSMutableDictionary dictionary];
    }
}

-(void)save {
    [NSKeyedArchiver archiveRootObject:archiveDict toFile:[archiveUrl path]];
    [self loadOrCreateArchiveDict];
}

-(void)refresh {
    [self loadOrCreateArchiveDict];
}

-(User *)primaryUser {
    
    NSString *primaryUserId = [archiveDict objectForKey:KeyForPrimaryUserId];
    User *primaryUser = [self userWithFacebookId:primaryUserId error:NULL];
    
    return primaryUser;
}

-(void)setPrimaryUser:(User *)user error:(NSError **)error {
        
    [archiveDict setObject:user.facebookId forKey:KeyForPrimaryUserId];
    
    [self save];
}

-(NSMutableArray *)allUsers {
        
    NSMutableArray *userArray = [archiveDict objectForKey:KeyForUserArray];
    NSLog(@"User array pointer: %p", userArray);
    if (userArray == nil) {
        userArray = [NSMutableArray array];
        [archiveDict setObject:userArray forKey:KeyForUserArray];
        NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:archiveDict];
        [archiveData writeToURL:archiveUrl atomically:YES];
    }
    
    return userArray;
}

-(User *)getOrCreateUserWithFacebookGraphUser:(id<FBGraphUser>)facebookUser {
    
    User *theUser = [self userWithFacebookId:facebookUser.id error:NULL];
    
    if (theUser == nil) {
        theUser = [self addFacebookUser:facebookUser];
    }
    return theUser;
}

-(User *)userWithFacebookId:(NSString *)facebookId error:(NSError **)error {
    
    NSMutableArray *users = [self allUsers];
    
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(User *evaluatedObject, NSDictionary *bindings) {
        BOOL retVal = NO;
        if ([evaluatedObject.facebookId isEqualToString:facebookId]) {
            retVal = YES;
        }
         return retVal;
     }];
    
    [users filterUsingPredicate:pred];
    
    User *user = nil;
    
    if ([users count] == 1) {
        user = [users objectAtIndex:0];
    }
    
    return user;
}

-(void)addUser:(User *)user error:(NSError *)error {
    
    NSMutableArray *users = [self allUsers];
    [users addObject:user];
}

-(User *)addFacebookUser:(id<FBGraphUser>)fbUser {
    
    User *newUser = [[User alloc] init];
    newUser.firstName = fbUser.first_name;
    newUser.lastName = fbUser.last_name;
    newUser.birthday = [[Utility_AppSettings dateFormatterForDisplay] dateFromString:fbUser.birthday];
    newUser.facebookId = fbUser.id;
    
    [self addUser:newUser error:NULL];
    
    return newUser;
}

-(void)removeUser:(User *)user error:(NSError *)error {
    
    NSMutableArray *users = [self allUsers];
    User *userInArray = [self userWithFacebookId:user.facebookId error:NULL];
    [users removeObject:userInArray];
}
    
@end
