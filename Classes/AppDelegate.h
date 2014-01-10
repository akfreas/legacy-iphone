@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(void)openSessionWithCompletionBlock:(void(^)(FBSession *, FBSessionState, NSError *))completionBlock;

@end
