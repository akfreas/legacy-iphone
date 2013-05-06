#import "MainScreen.h"
#import "EventInfoScrollView.h"
#import "FBLoginViewController.h"
#import "SettingsModalView.h"
#import "Person.h"
#import "ObjectArchiveAccessor.h"
#import "AFAlertView.h"
#import "Utility_AppSettings.h"
#import "FriendPickerHandler.h"
#import "Event.h"
#import "AtYourAgeWebView.h"

@implementation MainScreen {
    UINavigationController *viewForSettings;
    
    ObjectArchiveAccessor *accessor;
    FriendPickerHandler *friendPickerDelegate;
    FBFriendPickerViewController *friendPicker;
    IBOutlet EventInfoScrollView *infoScreen;
}


-(id)init {
    self = [super initWithNibName:@"MainScreen" bundle:[NSBundle mainBundle]];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertForNoBirthday:) name:KeyForNoBirthdayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToWikipedia:) name:KeyForWikipediaButtonTappedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePerson:) name:KeyForRemovePersonButtonTappedNotification object:nil];
    }
    return self;
}


-(void)removePerson:(NSNotification *)notification {
    Person *thePerson = notification.userInfo[@"person"];
    [accessor removePerson:thePerson];
    [infoScreen reload];
}

-(void)popToWikipedia:(NSNotification *)notification{
    
    Event *selectedEvent = notification.userInfo[@"event"];
    AtYourAgeWebView *webView = [[AtYourAgeWebView alloc] initWithEvent:selectedEvent];
    [self.navigationController pushViewController:webView animated:YES];
}

-(void)showAlertForNoBirthday:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    __block Person *thePerson = userInfo[KeyForPersonInBirthdayNotFoundNotification];
    accessor = [ObjectArchiveAccessor sharedInstance];
    AFAlertView *alertView = [[AFAlertView alloc] initWithTitle:@"No Birthday Found"];
    alertView.prompt = [NSString stringWithFormat:@"%@ doesn't have their full birthday listed.  Please correct the date below.", thePerson.firstName];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake(15, 0, 285, 44);
    textField.backgroundColor = [UIColor grayColor];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.font = [Utility_AppSettings applicationFontLarge];
    textField.accessibilityLabel = @"BirthdayInput";
    
    NSDate *newBirthday;
    
    if (thePerson.birthday != nil) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *birthdayComponents = [calendar components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit) fromDate:thePerson.birthday];
        newBirthday = [calendar dateFromComponents:birthdayComponents];
    } else {
        newBirthday = [NSDate date];
    }
    
    UIDatePicker *bDayDatePicker = [[UIDatePicker alloc] init];
    bDayDatePicker.datePickerMode = UIDatePickerModeDate;
    bDayDatePicker.date = newBirthday;
    bDayDatePicker.accessibilityLabel = @"BirthdayInput";

    
    
    [alertView insertUIComponent:bDayDatePicker atIndex:2];
    
    alertView.leftButtonTitle = @"Done";
    alertView.leftButtonActionBlock = ^(NSArray *uiComponents) {
        NSDate *birthday;
        for (UIView *component in uiComponents) {
            if ([component.accessibilityLabel isEqualToString:@"BirthdayInput"])  {
                birthday = [(UIDatePicker*)component date];
            }
        }
        NSLog(@"Chosen date: %@", birthday);
        thePerson.birthday = birthday;
        [accessor save];
        [infoScreen reload];
    };
    alertView.rightButtonTitle = @"Cancel";
    alertView.rightButtonActionBlock = ^(NSArray *uiComponents){
        [accessor removePerson:thePerson];
        [infoScreen reload];
    };
    [alertView showInView:self.view];
}

-(void)getUserBirthdayAndPlaceMainScreen {
    
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id <FBGraphUser>user, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                accessor = [ObjectArchiveAccessor sharedInstance];
                [accessor createAndSetPrimaryUser:user completionBlock:^(Person *thePerson) {
                    [infoScreen reload];
                }];
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
    [rightButtonView setBackgroundImage:[UIImage imageNamed:@"19-gear-gray.png"] forState:UIControlStateSelected];
    [rightButtonView addTarget:self action:@selector(showSettingsModalView) forControlEvents:UIControlEventTouchUpInside];
    
    [rightButtonHostView addSubview:rightButtonView];

    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:rightButtonHostView];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showFriendPicker)];
    self.navigationItem.rightBarButtonItem =  rightButton;
    
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"HeaderImg"] forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:176.0/256.0 green:167.0/256 blue:93.0/256 alpha:1];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"brushedmetal.png"]]];
//    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.opaque = NO;
}

-(void)showFriendPicker {
        friendPickerDelegate = [[FriendPickerHandler alloc] init];
        friendPicker = [[FBFriendPickerViewController alloc] init];
        friendPicker.delegate = friendPickerDelegate;
        friendPickerDelegate.friendPickerCompletionBlock = ^{
            [infoScreen reload];
        };
        friendPicker.session = [FBSession activeSession];
        Person *currentPerson = [accessor primaryPerson];
        friendPicker.userID = currentPerson.facebookId;
        [friendPicker loadData];
        [friendPicker presentModallyFromViewController:self animated:YES handler:friendPickerDelegate.completionHandler];
}


-(void)viewDidLoad {
    [super viewDidLoad];
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
    [self setNavigationElements];
}

                    
@end
