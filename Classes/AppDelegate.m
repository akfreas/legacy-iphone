#import "AppDelegate.h"
#import "MainScreen.h"
#import "FBLoginViewController.h"


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
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

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
