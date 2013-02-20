#import "EventInfoHostingView_old.h"
#import "YardstickRequest.h"
#import "YardstickConnection.h"
#import "Event.h"
#import "ObjectArchiveAccessor.h"
#import "AgeDisplaySegmentedControl.h"
#import "MainScreenWebView.h"
#import "SettingsModalView.h"
#import "FBLoginViewController.h"
#import "AgeArticleView.h"
#import "FriendTableViewController.h"
#import "FriendPickerHandler.h"
#import "Person.h"

@implementation EventInfoHostingView_old {
    
    IBOutlet UIWebView *articleWebView;
    IBOutlet FriendTableViewController *friendTableView;
    AgeArticleView *articleView;
    FriendPickerHandler *friendPickerDelegate;
    FBFriendPickerViewController *friendPicker;
    
    Person *currentPerson;
    ObjectArchiveAccessor *accessor;
    
    UINavigationController *viewForSettings;

}

@synthesize event;

-(id)init {
    self = [super initWithNibName:@"EventInfoHostingView" bundle:[NSBundle mainBundle]];
    
    if (self) {
        accessor = [ObjectArchiveAccessor sharedInstance];
    }
    
    return self;
}

-(void)refreshWithPerson:(Person *)person {
        YardstickRequest *request = [YardstickRequest requestToGetStoryForPerson:person];
        [articleWebView loadRequest:request.urlRequest];
        articleWebView.backgroundColor = [UIColor clearColor];
}

-(void)refreshWithPrimaryPerson {
    currentPerson = [accessor primaryPerson];
    if (currentPerson) {
        [self refreshWithPerson:currentPerson];
    }
    [friendTableView reload];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshWithPrimaryPerson];
    self.navigationItem.title = currentPerson.firstName;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    currentPerson = [accessor primaryPerson];
    
    [self.navigationController setNavigationBarHidden:NO];
    friendTableView.addFriendBlock = ^{

        friendPickerDelegate = [[FriendPickerHandler alloc] init];
        friendPicker = [[FBFriendPickerViewController alloc] init];
        friendPicker.delegate = friendPickerDelegate;
        friendPickerDelegate.friendPickerCompletionBlock = ^{
            [friendTableView reload];
        };
        friendPicker.session = [FBSession activeSession];
        friendPicker.userID = [currentPerson.facebookId stringValue];
        [friendPicker loadData];
        [friendPicker presentModallyFromViewController:self animated:YES handler:friendPickerDelegate.completionHandler];
    };
    friendTableView.personSelectedBlock = ^(Person *thePerson){
        [self refreshWithPerson:thePerson];
    };
}

-(void)dismissFriendPicker {
    [friendPicker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark FBFriendPicker delegate

-(void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
    
}

@end
