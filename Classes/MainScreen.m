#import "MainScreen.h"
#import "HorizontalContentHostingScrollView.h"
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
#import "ConnectToFacebookDialogView.h"
#import <MessageUI/MessageUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import <RNBlurModalView/RNBlurModalView.h>

@interface MainScreen ()  <MFMailComposeViewControllerDelegate>

@end

@implementation MainScreen {
    UINavigationController *viewForSettings;
    
    ObjectArchiveAccessor *accessor;
    FriendPickerHandler *friendPickerDelegate;
    FBFriendPickerViewController *friendPicker;
    IBOutlet HorizontalContentHostingScrollView *infoScreen;
    LegacyAppConnection *connection;
    MPMoviePlayerController *splashClipPlayer;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFriendButtonTapped:) name:KeyForFacebookButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePerson:) name:KeyForRemovePersonButtonTappedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentMailMessage) name:@"sendMail" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDataSync) name:UIApplicationDidBecomeActiveNotification object:nil];
        dataSync = [DataSyncUtility sharedInstance];
#if DEBUG != 1
        [self setupSplashClip];
#endif
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)setupSplashClip {
    
    NSString *clipPath = [[NSBundle mainBundle] pathForResource:@"splash-animation" ofType:@"mp4"];
    NSURL *clipURL = [NSURL fileURLWithPath:clipPath];
    splashClipPlayer = [[MPMoviePlayerController alloc] initWithContentURL:clipURL];
    splashClipPlayer.view.frame = self.view.bounds;
    splashClipPlayer.view.backgroundColor = HeaderBackgroundColor;
    splashClipPlayer.controlStyle = MPMovieControlStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeSplashView)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
 
    splashClipPlayer.scalingMode = MPMovieScalingModeFill;
    
    UIImageView *backgroundPlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launchimage.png"]];
    backgroundPlaceholder.backgroundColor = [UIColor redColor];
    [splashClipPlayer.view addSubview:backgroundPlaceholder];
    [self.view addSubview:splashClipPlayer.view];
}

-(void)removeSplashView {
    [UIView animateWithDuration:0.3 animations:^{
        splashClipPlayer.view.alpha = 0;
    } completion:^(BOOL finished) {
        [splashClipPlayer.view removeFromSuperview];
    }];
}

-(void)addFriendButtonTapped:(NSNotification *)notif {
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id <FBGraphUser>user, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showFriendPicker];
            });
        }];
    } else {
        [self showConnectToFBDialog];
    }
}

-(void)showConnectToFBDialog {
    RNBlurModalView *blurView;
    ConnectToFacebookDialogView *connectView = [[ConnectToFacebookDialogView alloc] initForAutoLayout];
    blurView = [[RNBlurModalView alloc] initWithParentView:self.view view:connectView];
    [blurView hideCloseButton:YES];
    connectView.dismissBlock = ^{
        [blurView hideWithDuration:FacebookModalPresentationDuration delay:0 options:0 completion:NULL];
    };
    [blurView showWithDuration:FacebookModalPresentationDuration delay:0 options:0 completion:NULL];
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

-(void)showFriendPicker {
    
    FBSessionState state = [FBSession activeSession].state;
        if (state == FBSessionStateOpen || state == FBSessionStateCreatedTokenLoaded) {
            DataSyncUtility *localDataSync = dataSync;
            if (friendPickerDelegate == nil) {
                friendPickerDelegate = [[FriendPickerHandler alloc] init];
            }
            friendPicker = [[FBFriendPickerViewController alloc] init];
            friendPicker.allowsMultipleSelection = NO;
            friendPicker.delegate = friendPickerDelegate;
            friendPickerDelegate.friendPickerCompletionBlock = ^{
                [localDataSync sync:NULL];
            };
            friendPicker.session = [FBSession activeSession];
            Person *currentPerson = [accessor primaryPerson];
            friendPicker.userID = currentPerson.facebookId;
            [friendPicker loadData];
            [friendPicker presentModallyFromViewController:self animated:YES handler:friendPickerDelegate.completionHandler];
            
        } else {
            [self showConnectToFBDialog];
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
        [Flurry logEvent:@"delete_person_confirmed" withParameters:@{@"person": personToDelete.facebookId}];
        [delConnection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ObjectArchiveAccessor sharedInstance] removePerson:personToDelete];
            });
        }];
        
    };
    
    alert.rightButtonTitle = @"NO";
    
    [alert showInView:self.view];
}

- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(void)presentMailMessage {
    MFMailComposeViewController *composeController = [[MFMailComposeViewController alloc] init];
    [composeController setSubject:@"Hello!"];
    [composeController setToRecipients:@[@"apps@sashimiblade.com"]];
    
    NSURL *dbPath = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Legacy.sqlite"]];
    NSData *data = [NSData dataWithContentsOfURL:dbPath];
    [composeController addAttachmentData:data mimeType:@"application/x-legacyapp-data" fileName:@"legacy-database"];
    composeController.mailComposeDelegate = self;
    [self presentViewController:composeController animated:YES completion:NULL];
    
}
#pragma mark Mail Compose Delegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


-(void)startDataSync {
    
    if ([self shouldSyncNow]) {
        [dataSync sync:NULL];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#if DEBUG != 1
    splashClipPlayer.view.frame = xxx self.view.bounds;
    [splashClipPlayer play];
#endif
}


@end
