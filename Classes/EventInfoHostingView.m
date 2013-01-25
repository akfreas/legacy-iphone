#import "EventInfoHostingView.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "Event.h"
#import "ObjectArchiveAccessor.h"
#import "SwitchPerson.h"
#import "AgeDisplaySegmentedControl.h"
#import "MainScreenWebView.h"
#import "SettingsModalView.h"
#import "FBLoginViewController.h"
#import "AgeArticleView.h"
#import "User.h"

static NSString *KeyForName = @"name";
static NSString *KeyForBirthday = @"birthday";

@implementation EventInfoHostingView {
    
    IBOutlet UIWebView *articleWebView;
    AgeArticleView *articleView;
    
    AgeDisplaySegmentedControl *ageDisplay;
    User *currentUser;
    ObjectArchiveAccessor *accessor;
    
    UINavigationController *viewForSettings;
}

@synthesize event;

-(id)init {
    self = [super initWithNibName:@"EventInfoHostingView" bundle:[NSBundle mainBundle]];
    
    if (self) {
        accessor = [[ObjectArchiveAccessor alloc] init];
        currentUser = [accessor primaryUser];
        NSLog(@"Current user: %@", currentUser);
    }
    
    return self;
}

-(void)refresh {
    
//        [articleView updateWithUser:currentUser];
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
        AtYourAgeRequest *request = [AtYourAgeRequest requestToGetStoryForUser:currentUser];
        [articleWebView loadRequest:request.urlRequest];
        articleWebView.backgroundColor = [UIColor clearColor];
    }
    [self.navigationController setNavigationBarHidden:NO];
    
}

@end
