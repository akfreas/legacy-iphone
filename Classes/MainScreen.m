#import "MainScreen.h"
#import "LeftRightHostingScrollView.h"
#import "FBLoginViewController.h"
#import "SettingsModalView.h"
#import "Person.h"
#import "ObjectArchiveAccessor.h"
#import "AFAlertView.h"
#import "Utility_AppSettings.h"
#import "FriendPickerHandler.h"
#import "Event.h"
#import "LegacyWebView.h"
#import "LegacyAppConnection.h"
#import "LegacyAppRequest.h"
#import "DataSyncUtility.h"

@implementation MainScreen {
    UINavigationController *viewForSettings;
    
    ObjectArchiveAccessor *accessor;
    FriendPickerHandler *friendPickerDelegate;
    FBFriendPickerViewController *friendPicker;
    IBOutlet LeftRightHostingScrollView *infoScreen;
    LegacyAppConnection *connection;
    
    __unsafe_unretained DataSyncUtility *dataSync;
}


-(id)init {
    self = [super initWithNibName:@"MainScreen" bundle:[NSBundle mainBundle]];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertForNoBirthday:) name:KeyForNoBirthdayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToWikipedia:) name:KeyForWikipediaButtonTappedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePerson:) name:KeyForRemovePersonButtonTappedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFriendPicker) name:KeyForAddFriendButtonTapped object:nil];
        dataSync = [DataSyncUtility sharedInstance];
    }
    return self;
}


-(void)removePerson:(NSNotification *)notification {
    Person *thePerson = notification.userInfo[@"person"];
    [accessor removePerson:thePerson];
    [infoScreen reload];
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
        
        LegacyAppRequest *updateBirthdayRequest = [LegacyAppRequest requestToUpdateBirthday:birthday forPerson:thePerson];
        connection = [[LegacyAppConnection alloc] initWithLegacyRequest:updateBirthdayRequest];
        
        [connection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
            NSLog(@"result: %@", result);
        }];
                
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

-(void)showFriendPicker {
        friendPickerDelegate = [[FriendPickerHandler alloc] init];
        friendPicker = [[FBFriendPickerViewController alloc] init];
        friendPicker.delegate = friendPickerDelegate;
        friendPickerDelegate.friendPickerCompletionBlock = ^{
            [dataSync sync:^{
                
            }];
        };
        friendPicker.session = [FBSession activeSession];
        Person *currentPerson = [accessor primaryPerson];
        friendPicker.userID = currentPerson.facebookId;
        [friendPicker loadData];
        [friendPicker presentModallyFromViewController:self animated:YES handler:friendPickerDelegate.completionHandler];
}

-(void)reloadScreen {
    [infoScreen reload];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.frame = CGRectInset(self.view.frame, 0, 0);
    [self.view addSubview:activity];
    [activity startAnimating];
    [dataSync sync:^{
        [activity stopAnimating];
        [infoScreen reload];
    }];
}

                    
@end
