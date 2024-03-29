#import "MainScreen.h"
#import "HorizontalContentHostingScrollView.h"
#import "SettingsModalView.h"
#import "Person.h"
#import "Figure.h"
#import "FixtureFactory.h"
#import "TourScreenViewController.h"
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
#import <RNBlurModalView/RNBlurModalView.h>
#import <AFFacebook-iOS-SDK/FacebookSDK/Facebook.h>
#import "ConfigurationUtil.h"

@interface MainScreen ()  <MFMailComposeViewControllerDelegate>

@end

@implementation MainScreen {
    UINavigationController *viewForSettings;
    RNBlurModalView *blurView;
    FriendPickerHandler *friendPickerDelegate;
    FBFriendPickerViewController *friendPicker;
    IBOutlet HorizontalContentHostingScrollView *infoScreen;
    LegacyAppConnection *connection;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFriendPicker) name:FacebookActionButtonTappedNotificationKey object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFriendButtonTapped:) name:FacebookActionButtonTappedNotificationKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePerson:) name:KeyForRemovePersonButtonTappedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentMailMessage) name:@"sendMail" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDataSync) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tourCompleted) name:KeyForTourCompletedNotification object:nil];
#if DEBUG != 1
//        [self setupSplashClip];
#endif
    }
    return self;
}


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    if (blurView == nil) {
        ConnectToFacebookDialogView *connectView = [[ConnectToFacebookDialogView alloc] initForAutoLayout];
        blurView = [[RNBlurModalView alloc] initWithParentView:self.view view:connectView];
//        [AKNOTIF addObserver:self selector:@selector(forceDataSync) name:KeyForLoggedIntoFacebookNotification object:nil];
        [blurView hideCloseButton:YES];
        connectView.dismissBlock = ^{
            [blurView hideWithDuration:FacebookModalPresentationDuration delay:0 options:0 completion:^{
                blurView = nil;
            }];
        };
        [blurView showWithDuration:FacebookModalPresentationDuration delay:0 options:0 completion:NULL];
    }
}

-(void)showFriendPicker {
    
    FBSessionState state = [FBSession activeSession].state;
        if (state == FBSessionStateOpen || state == FBSessionStateCreatedTokenLoaded) {
            if (friendPickerDelegate == nil) {
                friendPickerDelegate = [[FriendPickerHandler alloc] init];
            }
            friendPicker = [[FBFriendPickerViewController alloc] init];
            friendPicker.selection = friendPickerDelegate.friendPickerControllerSelection = [self selectedFacebookUsers];
            friendPicker.delegate = friendPickerDelegate;
            friendPicker.indicateUserBirthday = YES;
            friendPickerDelegate.friendPickerCompletionBlock = ^{
                [[DataSyncUtility sharedInstance] sync:NULL];
            };
            friendPicker.session = [FBSession activeSession];
            Person *currentPerson = [Person primaryPersonInContext:nil];
            friendPicker.userID = currentPerson.facebookId;
            [friendPicker loadData];
            [friendPicker presentModallyFromViewController:self animated:YES handler:friendPickerDelegate.completionHandler];
            
        } else {
            [self showConnectToFBDialog];
        }
}

-(NSArray *)selectedFacebookUsers {
    NSArray *fbPersons = [Person allPersonsInContext:nil includePrimary:NO];
    NSMutableArray *fbUsers = [NSMutableArray array];
    for (Person *person in fbPersons) {
        id<FBGraphUser> fbUser = (id<FBGraphUser>)[FBGraphObject graphObject];
        fbUser.id = person.facebookId;
        fbUser.first_name = person.firstName;
        fbUser.last_name = person.lastName;
        [fbUsers addObject:fbUser];
    }
    return [NSArray arrayWithArray:fbUsers];
}

-(BOOL)shouldSyncNow {

    if ([ConfigurationUtil appHasBeenUpgraded] == YES) {
        return YES;
    }
    
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

-(void)forceDataSync {
    [[DataSyncUtility sharedInstance] sync:NULL];
}

-(void)startDataSync {
    if (blurView != nil) {
        [blurView hide];
        blurView = nil;
    }
    [LegacyAppConnection get:[LegacyAppRequest requestToGetConfiguration] withCompletionBlock:^(LegacyAppRequest *request, NSDictionary *configJSON, NSError *error) {
        [ConfigurationUtil saveConfigFromJSON:configJSON];
    }];
    if ([self shouldSyncNow]) {
        [[DataSyncUtility sharedInstance] sync:^{
            [ConfigurationUtil saveCurrentAppVersion];
        }];
    }
}

-(void)tourCompleted {
    [UIView animateWithDuration:1.0f animations:^{
        self.view.alpha = 1;
    }];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    BOOL tourShown = [[NSUserDefaults standardUserDefaults] boolForKey:KeyForHasBeenShownTour];
    if (tourShown == NO) {
        self.view.alpha = 0;
    } 
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BOOL tourShown = [[NSUserDefaults standardUserDefaults] boolForKey:KeyForHasBeenShownTour];
    if (tourShown != YES) {
        [self presentViewController:[TourScreenViewController new] animated:YES completion:NULL];
    }
}


@end
