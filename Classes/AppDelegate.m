#import "AppDelegate.h"
#import "MainScreen.h"
#import "FBLoginViewController.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "ObjectArchiveAccessor.h"

@implementation AppDelegate {
    
    UINavigationController *mainNavController;
}

@synthesize window = _window;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

-(void)configureInitialViewHeirarchy {
    
    MainScreen *mainScreen = [[MainScreen alloc] init];
    
    mainNavController = [[UINavigationController alloc] initWithRootViewController:mainScreen];
    [mainNavController setNavigationBarHidden:NO];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [FBProfilePictureView class];
    [self configureInitialViewHeirarchy];
    MainScreen *mainScreen = [[MainScreen alloc] init];

    self.window.rootViewController = mainScreen;
    
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
    Person *mainPerson = [[ObjectArchiveAccessor sharedInstance] primaryPerson];
    LegacyAppRequest *request = [LegacyAppRequest requestToPostDeviceInformation:deviceDict person:mainPerson];
    LegacyAppConnection *connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
    
    [connection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
        NSLog(@"APNS result: %@", result);
    }];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Could not register for notifications: %@", error);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBSession.activeSession handleOpenURL:url];
}

-(void)openSessionWithCompletionBlock:(void(^)(FBSession *, FBSessionState, NSError *))completionBlock {
    
    NSArray *perms = [NSArray arrayWithObjects:@"user_birthday", @"friends_birthday", nil];
    [FBSession openActiveSessionWithReadPermissions:perms
                                       allowLoginUI:YES
                                  completionHandler:completionBlock];
}

@end
