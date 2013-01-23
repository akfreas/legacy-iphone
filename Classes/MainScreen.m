#import "MainScreen.h"
#import "AgeInfoScreen.h"
#import "FBLoginViewController.h"
#import "Utility_UserInfo.h"
#import "SettingsModalView.h"
#import "SwitchPerson.h"

@implementation MainScreen {
    UINavigationController *viewForSettings;
}


-(void)placeAgeInfoView {
    
    AgeInfoScreen *infoScreen = [[AgeInfoScreen alloc] init];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self addChildViewController:infoScreen];
    [self.view addSubview:infoScreen.view];
}

-(void)getUserBirthdayAndPlaceMainScreen {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    NSLog(@"FB Session: %@", FBSession.activeSession);
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id <FBGraphUser>user, NSError *error) {
            NSDate *birthday = [formatter dateFromString:user.birthday];
            NSLog(@"Birthday parsed %@", birthday);
            [Utility_UserInfo setCurrentName:user.name];
            [Utility_UserInfo setOrUpdateUserBirthday:birthday name:user.name];
            [self placeAgeInfoView];
            [self setNavigationElements];
        }];
    }
}

-(void)switchPerson {
    
    SwitchPerson *switchPerson = [[SwitchPerson alloc] init];
    
    [self.navigationController pushViewController:switchPerson animated:YES];
    
}

-(void)showSettingsModalView {
    
    if (viewForSettings == nil) {
        viewForSettings = [[UINavigationController alloc] initWithRootViewController:[[SettingsModalView alloc] init]];
    }
    [self presentViewController:viewForSettings animated:YES completion:NULL];
}

-(void)setNavigationElements {
    
    self.navigationController.title = [Utility_UserInfo currentName];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(switchPerson)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsModalView)];
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}

-(void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.view = view;
}


-(void)viewDidAppear:(BOOL)animated {
    
//    FBSession *session = [[FBSession alloc] init];
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    NSLog(@"FB Session state in mainscreen: %@", FBSession.activeSession);
    if (FBSession.activeSession.state != FBSessionStateOpen) {
        FBLoginViewController *loadScreen = [[FBLoginViewController alloc] initWithLoggedInCompletion:^{
            [self getUserBirthdayAndPlaceMainScreen];
        }];
        [self presentViewController:loadScreen animated:NO completion:NULL];
    } else {
        [self getUserBirthdayAndPlaceMainScreen];
    }
}


                    
@end
