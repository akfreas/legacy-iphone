#import "MainScreen.h"
#import "EventInfoHostingView.h"
#import "FBLoginViewController.h"
#import "Utility_UserInfo.h"
#import "SettingsModalView.h"
#import "SwitchPerson.h"
#import "ObjectArchiveAccessor.h"

@implementation MainScreen {
    UINavigationController *viewForSettings;
    
    ObjectArchiveAccessor *accessor;
}


-(void)placeEventHostingView {
    
    EventInfoHostingView *infoScreen = [[EventInfoHostingView alloc] init];
    [self addChildViewController:infoScreen];
    [self.view addSubview:infoScreen.view];
}

-(void)getUserBirthdayAndPlaceMainScreen {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    accessor = [[ObjectArchiveAccessor alloc] init];
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id <FBGraphUser>user, NSError *error) {
            NSDate *birthday = [formatter dateFromString:user.birthday];
            NSLog(@"Birthday parsed %@", birthday);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                User *primaryUser = [accessor getOrCreateUserWithFacebookGraphUser:user];
                [accessor setPrimaryUser:primaryUser error:NULL];
                [accessor save];
            });
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
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(switchPerson)];
    
    
    CGFloat leftPadding = 6;
    UIImageView *rightButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"19-gear.png"]];
    UIView *rightButtonHostView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rightButtonImageView.frame), CGRectGetHeight(rightButtonImageView.frame))];
    UIButton *rightButtonView = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, 0, CGRectGetWidth(rightButtonImageView.frame), CGRectGetHeight(rightButtonImageView.frame))];
    [rightButtonView setBackgroundImage:[UIImage imageNamed:@"19-gear.png"] forState:UIControlStateNormal];
    [rightButtonView setBackgroundImage:[UIImage imageNamed:@"19-gear-gray.png"] forState:UIControlEventTouchUpInside];
    [rightButtonView addTarget:self action:@selector(showSettingsModalView) forControlEvents:UIControlEventTouchUpInside];
    
    [rightButtonHostView addSubview:rightButtonView];

    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightButtonHostView];
    self.navigationItem.leftBarButtonItem = rightButton;
    
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"HeaderImg"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:176.0/256.0 green:167.0/256 blue:93.0/256 alpha:1];
    self.navigationController.navigationBar.opaque = NO;
}

-(void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.view = view;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationElements];
    [self placeEventHostingView];
}

-(void)viewDidAppear:(BOOL)animated {
    
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
