#import "MainScreen.h"
#import "LeftRightHostingScrollView.h"
#import "FBLoginViewController.h"
#import "SettingsModalView.h"
#import "Person.h"
#import "Figure.h"
#import "ObjectArchiveAccessor.h"
#import "AFAlertView.h"
#import "Utility_AppSettings.h"
#import "FriendPickerHandler.h"
#import "Event.h"
#import "LegacyWebView.h"
#import "LegacyAppConnection.h"
#import "LegacyAppRequest.h"
#import "DataSyncUtility.h"
#import "FacebookUtils.h"


@implementation MainScreen {
    UINavigationController *viewForSettings;
    
    ObjectArchiveAccessor *accessor;
    FriendPickerHandler *friendPickerDelegate;
    FBFriendPickerViewController *friendPicker;
    IBOutlet LeftRightHostingScrollView *infoScreen;
    LegacyAppConnection *connection;
    
    __unsafe_unretained DataSyncUtility *dataSync;
}


+(MainScreen *)sharedInstance {
    static MainScreen *instance;
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[MainScreen alloc] init];
        });
    }
    return instance;
}

-(id)init {
    self = [super initWithNibName:@"MainScreen" bundle:[NSBundle mainBundle]];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFriendPicker) name:KeyForAddFriendButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showShareDialog:) name:KeyForFacebookButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePerson:) name:KeyForRemovePersonButtonTappedNotification object:nil];

        dataSync = [DataSyncUtility sharedInstance];
    }
    return self;
}

-(void)showShareDialog:(NSNotification *)notif {
    
    Event *event = notif.userInfo[@"event"];
    NSString *eventAgeString = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", event.ageYears, event.ageMonths, event.ageDays];
    
    NSString *nameWithUnderscores = [event.figure.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSURL *wikipediaUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", nameWithUnderscores]];
    [FBDialogs presentShareDialogWithLink:wikipediaUrl name:event.figure.name caption:eventAgeString description:event.eventDescription picture:[NSURL URLWithString:event.figure.imageURL] clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        
    }];
    
    
}



-(void)showAlertForNoBirthday:(Person *)thePerson completion:(void(^)(Person *person))completion cancellation:(void(^)(Person *person))cancellation {
    
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
        completion(thePerson);
    };
    alertView.rightButtonTitle = @"Cancel";
    alertView.rightButtonActionBlock = ^(NSArray *uiComponents){
        cancellation(thePerson);
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
    FBSessionState state = [FBSession activeSession].state;
        if (state == FBSessionStateOpen || state == FBSessionStateCreatedTokenLoaded) {
            friendPickerDelegate = [[FriendPickerHandler alloc] init];
            friendPicker = [[FBFriendPickerViewController alloc] init];
            friendPicker.allowsMultipleSelection = NO;
            friendPicker.delegate = friendPickerDelegate;
            friendPickerDelegate.friendPickerCompletionBlock = ^{
                [dataSync sync:NULL];
            };
            friendPicker.session = [FBSession activeSession];
            Person *currentPerson = [accessor primaryPerson];
            friendPicker.userID = currentPerson.facebookId;
            [friendPicker loadData];
            [friendPicker presentModallyFromViewController:self animated:YES handler:friendPickerDelegate.completionHandler];
            
        } else {
            AFAlertView *alert = [[AFAlertView alloc] initWithTitle:@"Connect to Facebook?"];
            alert.description = @"Connecting to Facebook allows you to discover what happened in someone else's life at your friend's exact age.";
            alert.leftButtonActionBlock = ^(NSArray *components) {
                [FacebookUtils loginWithFacebook:NULL];
            };
            alert.leftButtonTitle = @"OK";
            alert.rightButtonTitle = @"No Thanks";
            [alert showInView:self.view];
        }
}


-(BOOL)shouldSyncNow {
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:KeyForLastDateSynced];
    if (lastDate == nil) {
        return YES;
    }
    
    if ([(NSDate *)[lastDate dateByAddingTimeInterval:60*60*24] compare:[NSDate date]] == NSOrderedAscending) {
        return YES;
    } else {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger dayOfLastDate = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSYearCalendarUnit forDate:lastDate];
        NSUInteger dayOfCurrentDate = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate date]];
        NSInteger dateDifference = abs(dayOfLastDate - dayOfCurrentDate);
        
        if (dateDifference > 0) {
            return YES;
        } else {
            return NO;
        }
    }
}

-(void)deletePerson:(NSNotification *)notif {
    
    Person *personToDelete = notif.userInfo[@"person"];
    
    
    AFAlertView *alert = [[AFAlertView alloc] initWithTitle:@"Confirm"];
    alert.description = [NSString stringWithFormat:@"Are you sure you want to remove %@?", personToDelete.firstName];
    alert.leftButtonTitle = @"YES";
    alert.leftButtonActionBlock = ^(NSArray *components){
        
        LegacyAppRequest *requestToDelete = [LegacyAppRequest requestToDeletePerson:personToDelete];
        LegacyAppConnection *delConnection = [[LegacyAppConnection alloc] initWithLegacyRequest:requestToDelete];
        
        [delConnection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ObjectArchiveAccessor sharedInstance] removePerson:personToDelete];
            });
        }];
        
    };
    
    alert.rightButtonTitle = @"NO";
    
    [alert showInView:self.view];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self shouldSyncNow]) {
        [dataSync sync:NULL];
    }
}


@end
