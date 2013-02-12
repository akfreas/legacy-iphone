    #import "EventInfoHostingView.h"
#import "YardstickRequest.h"
#import "YardstickConnection.h"
#import "Event.h"
#import "ObjectArchiveAccessor.h"
#import "SwitchPerson.h"
#import "AgeDisplaySegmentedControl.h"
#import "MainScreenWebView.h"
#import "SettingsModalView.h"
#import "FBLoginViewController.h"
#import "AgeArticleView.h"
#import "FriendTableViewController.h"
#import "FriendPickerHandler.h"
#import "User.h"

static NSString *KeyForName = @"name";
static NSString *KeyForBirthday = @"birthday";

@implementation EventInfoHostingView {
    
    IBOutlet UIWebView *articleWebView;
    IBOutlet FriendTableViewController *friendTableView;
    AgeArticleView *articleView;
    FriendPickerHandler *friendPickerDelegate;
    FBFriendPickerViewController *friendPicker;
    
    User *currentUser;
    ObjectArchiveAccessor *accessor;
    
    UINavigationController *viewForSettings;

}

@synthesize event;

-(id)init {
    self = [super initWithNibName:@"EventInfoHostingView" bundle:[NSBundle mainBundle]];
    
    if (self) {
        accessor = [ObjectArchiveAccessor sharedInstance];
        currentUser = [accessor primaryUser];
    }
    
    return self;
}

-(void)refresh {
    
//        [articleView updateWithPerson:currentUser];
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    currentUser = [accessor primaryUser];
    
    self.navigationItem.title = currentUser.firstName;
    [self refresh];
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (currentUser) {
        YardstickRequest *request = [YardstickRequest requestToGetStoryForPerson:currentUser];
        [articleWebView loadRequest:request.urlRequest];
        articleWebView.backgroundColor = [UIColor clearColor];
    }
    [self.navigationController setNavigationBarHidden:NO];
    friendTableView.addFriendBlock = ^{
        friendPickerDelegate = [[FriendPickerHandler alloc] init];
        friendPicker = [[FBFriendPickerViewController alloc] init];
        friendPicker.delegate = friendPickerDelegate;
        friendPicker.session = [FBSession activeSession];
        friendPicker.userID = currentUser.facebookId;
        [friendPicker loadData];

        [friendPicker presentModallyFromViewController:self animated:YES handler:friendPickerDelegate.completionHandler];
    };
}

-(void)dismissFriendPicker {
    [friendPicker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark FBFriendPicker delegate

-(void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
    
}

@end
