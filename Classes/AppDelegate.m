#import "AppDelegate.h"
#import "MainScreen.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "GAI.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <BugSense-iOS/BugSenseController.h>
@implementation AppDelegate 

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
//    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#if DEBUG==0
    [BugSenseController sharedControllerWithBugSenseAPIKey:@"6e2eee3d"];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
#endif
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    MainScreen *mainScreen = [MainScreen sharedInstance];
    self.window.rootViewController = mainScreen;
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"Token: %@", hexToken);
    NSDictionary *deviceDict = @{@"device_token": hexToken};
    Person *mainPerson = [Person primaryPersonInContext:nil];
    LegacyAppRequest *request = [LegacyAppRequest requestToPostDeviceInformation:deviceDict person:mainPerson];
    [LegacyAppConnection get:request withCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
        NSLog(@"APNS Result: %@", result);
    }];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Could not register for notifications: %@", error);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForLoggedIntoFacebookNotification object:nil];
    return [FBSession.activeSession handleOpenURL:url];
}

+(void)openSessionWithCompletionBlock:(void(^)(FBSession *, FBSessionState, NSError *))completionBlock {
    
    BOOL hasAuthenticated = [[NSUserDefaults standardUserDefaults] boolForKey:KeyForUserHasAuthenticatedWithFacebook];
    
    if (hasAuthenticated == YES) {
        NSArray *perms = [NSArray arrayWithObjects:@"user_birthday", @"friends_birthday", nil];
        [FBSession openActiveSessionWithReadPermissions:perms
                                           allowLoginUI:YES
                                      completionHandler:completionBlock];
    } 
}

@end
