#import "FBLoginViewController.h"
#import "AppDelegate.h"

@implementation FBLoginViewController {
    
    void(^loggedInCompletion)();
}

-(id)initWithLoggedInCompletion:(void(^)())loggedInCompletionBlock {
    self = [super initWithNibName:@"FBLoginView" bundle:[NSBundle mainBundle]];
    
    if (self) {
        loggedInCompletion = [loggedInCompletionBlock copy];
    }
    return self;
}



-(IBAction)performLogin:(id)sender {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [appDelegate openSessionWithCompletionBlock:^(FBSession *session, FBSessionState state, NSError *error) {
        switch (state) {
            case FBSessionStateOpen:
                loggedInCompletion();
                break;
            case FBSessionStateClosed:
                break;
            case FBSessionStateClosedLoginFailed:
                break;
            default:
                break;
        }
        
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:error.localizedDescription
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

@end
