#import "MainScreen.h"
#import "HorizontalContentHostingScrollView.h"
#import "SettingsModalView.h"
#import "Person.h"
#import "Figure.h"

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
#import <AFFacebook-iOS-SDK/FacebookSDK/Facebook.h>

@interface MainScreen ()  <MFMailComposeViewControllerDelegate>

@end

@implementation MainScreen {
    UINavigationController *viewForSettings;
    RNBlurModalView *blurView;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFriendPicker) name:FacebookActionButtonTappedNotificationKey object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFriendButtonTapped:) name:FacebookActionButtonTappedNotificationKey object:nil];
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

-(void)showShareDialog:(NSNotification *)notif {
    
    Event *event = notif.userInfo[@"event"];
    NSString *eventAgeString = [NSString stringWithFormat:@"@%@ years, %@ months, %@ days old ", event.ageYears, event.ageMonths, event.ageDays];
    NSString *eventDescriptionString = [NSString stringWithFormat:@"%@: %@", eventAgeString, event.eventDescription];
    NSString *nameWithUnderscores = [event.figure.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSURL *wikipediaUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", nameWithUnderscores]];
    [FBDialogs presentShareDialogWithLink:wikipediaUrl name:event.figure.name caption:eventAgeString description:eventDescriptionString picture:[NSURL URLWithString:event.figure.imageURL] clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        
    }];
    
    
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
        splashClipPlayer = nil;
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
    ConnectToFacebookDialogView *connectView = [[ConnectToFacebookDialogView alloc] initForAutoLayout];
    blurView = [[RNBlurModalView alloc] initWithParentView:self.view view:connectView];
    [AKNOTIF addObserver:self selector:@selector(startDataSync) name:KeyForLoggedIntoFacebookNotification object:nil];
    [blurView hideCloseButton:YES];
    connectView.dismissBlock = ^{
        [blurView hideWithDuration:FacebookModalPresentationDuration delay:0 options:0 completion:NULL];
    };
    [blurView showWithDuration:FacebookModalPresentationDuration delay:0 options:0 completion:NULL];
}

-(void)showFriendPicker {
    
    FBSessionState state = [FBSession activeSession].state;
        if (state == FBSessionStateOpen || state == FBSessionStateCreatedTokenLoaded) {
            DataSyncUtility *localDataSync = dataSync;
            if (friendPickerDelegate == nil) {
                friendPickerDelegate = [[FriendPickerHandler alloc] init];
            }
            friendPicker = [[FBFriendPickerViewController alloc] init];
            friendPicker.selection = friendPickerDelegate.friendPickerControllerSelection = [self selectedFacebookUsers];
            friendPicker.delegate = friendPickerDelegate;
            friendPicker.indicateUserBirthday = YES;
            friendPickerDelegate.friendPickerCompletionBlock = ^{
                [localDataSync sync:NULL];
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


-(void)startDataSync {
    if (blurView != nil) {
        [blurView hide];
        blurView = nil;
    }
    if ([self shouldSyncNow]) {
        [dataSync sync:NULL];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#if DEBUG != 1
    if (splashClipPlayer != nil) {
        splashClipPlayer.view.frame = self.view.bounds;
        [splashClipPlayer play];
    }
#endif
}


@end
