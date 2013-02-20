#import "MainScreen.h"
#import "EventInfoScrollView.h"
#import "FBLoginViewController.h"
#import "SettingsModalView.h"
#import "Person.h"
#import "ObjectArchiveAccessor.h"
#import "AFAlertView.h"
#import "Utility_AppSettings.h"
#import "FriendPickerHandler.h"

@implementation MainScreen {
    UINavigationController *viewForSettings;
    
    ObjectArchiveAccessor *accessor;
    FriendPickerHandler *friendPickerDelegate;
    FBFriendPickerViewController *friendPicker;
    EventInfoScrollView *infoScreen;
}


-(id)init {
    self = [super initWithNibName:@"MainScreen" bundle:[NSBundle mainBundle]];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertForNoBirthday:) name:KeyForNoBirthdayNotification object:nil];
    }
    return self;
}

-(void)showAlertForNoBirthday:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    __block Person *thePerson = userInfo[KeyForPersonInBirthdayNotFoundNotification];
    accessor = [ObjectArchiveAccessor sharedInstance];
    AFAlertView *alertView = [[AFAlertView alloc] initWithTitle:@"No Birthday Found"];
    alertView.prompt = [NSString stringWithFormat:@"%@ doesn't have their full birthday listed.  Please enter the year they were born below.", thePerson.firstName];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake(15, 0, 285, 44);
    textField.backgroundColor = [UIColor grayColor];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.font = [Utility_AppSettings applicationFontLarge];
    textField.accessibilityLabel = @"BirthdayInput";
    [alertView insertUIComponent:textField atIndex:2];
    
    alertView.leftButtonTitle = @"Done";
    alertView.leftButtonActionBlock = ^(NSArray *uiComponents) {
        NSString *birthYear;
        for (UIView *component in uiComponents) {
            if ([component.accessibilityLabel isEqualToString:@"BirthdayInput"])  {
                birthYear = [(UITextField*)component text];
            }
        }
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *birthdayComponents = [calendar components:(NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:thePerson.birthday];
        [birthdayComponents setYear:[birthYear integerValue]];
        NSDate *newBirthday = [calendar dateFromComponents:birthdayComponents];
        thePerson.birthday = newBirthday;
        [accessor save];
    };
    [alertView showInView:self.view];
}

-(void)placeEventHostingView {
    
    infoScreen = [[EventInfoScrollView alloc] init];
    infoScreen.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    [self.view addSubview:infoScreen];
//    [self.navigationController pushViewController:infoScreen animated:NO];
}

-(void)getUserBirthdayAndPlaceMainScreen {
    
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id <FBGraphUser>user, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                accessor = [ObjectArchiveAccessor sharedInstance];
                Person *primaryFriend = [accessor getOrCreatePersonWithFacebookGraphUser:user];
                [accessor setPrimaryPerson:primaryFriend];
                
                if (infoScreen == nil) {
                    [self placeEventHostingView];
                } else {
//                    [infoScreen refreshWithPrimaryPerson];
                }
            });
        }];
    }
}


-(void)showSettingsModalView {
    
    if (viewForSettings == nil) {
        viewForSettings = [[UINavigationController alloc] initWithRootViewController:[[SettingsModalView alloc] init]];
    }
    [self presentViewController:viewForSettings animated:YES completion:NULL];
}

-(void)setNavigationElements {
    
    Person *primaryPerson = [[ObjectArchiveAccessor sharedInstance] primaryPerson];
    self.navigationController.title = primaryPerson.firstName;
    
    CGFloat leftPadding = 6;
    UIImageView *rightButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"19-gear.png"]];
    UIView *rightButtonHostView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rightButtonImageView.frame), CGRectGetHeight(rightButtonImageView.frame))];
    UIButton *rightButtonView = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, 0, CGRectGetWidth(rightButtonImageView.frame), CGRectGetHeight(rightButtonImageView.frame))];
    [rightButtonView setBackgroundImage:[UIImage imageNamed:@"19-gear.png"] forState:UIControlStateNormal];
    [rightButtonView setBackgroundImage:[UIImage imageNamed:@"19-gear-gray.png"] forState:UIControlEventTouchUpInside];
    [rightButtonView addTarget:self action:@selector(showSettingsModalView) forControlEvents:UIControlEventTouchUpInside];
    
    [rightButtonHostView addSubview:rightButtonView];

    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:rightButtonHostView];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showFriendPicker)];
    self.navigationItem.rightBarButtonItem =  rightButton;
    
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"HeaderImg"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:176.0/256.0 green:167.0/256 blue:93.0/256 alpha:1];
    self.navigationController.navigationBar.opaque = NO;
}

-(void)showFriendPicker {
        friendPickerDelegate = [[FriendPickerHandler alloc] init];
        friendPicker = [[FBFriendPickerViewController alloc] init];
        friendPicker.delegate = friendPickerDelegate;
        friendPickerDelegate.friendPickerCompletionBlock = ^{
        };
        friendPicker.session = [FBSession activeSession];
        Person *currentPerson = [accessor primaryPerson];
        friendPicker.userID = [currentPerson.facebookId stringValue];
        [friendPicker loadData];
        [friendPicker presentModallyFromViewController:self animated:YES handler:friendPickerDelegate.completionHandler];
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationElements];
    [self placeEventHostingView];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    if (FBSession.activeSession.state != FBSessionStateOpen) {
        FBLoginViewController *loadScreen = [[FBLoginViewController alloc] initWithLoggedInCompletion:^{
            [self dismissViewControllerAnimated:YES completion:^{
                [self getUserBirthdayAndPlaceMainScreen];
            }];
        }];
        [self presentViewController:loadScreen animated:NO completion:NULL];
    } else {
        [self getUserBirthdayAndPlaceMainScreen];
    }
}


                    
@end
