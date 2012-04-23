#import "MainScreen.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "Event.h"
#import "Utility_UserInfo.h"
#import "SwitchPerson.h"
#import "AgeDisplaySegmentedControl.h"
#import "MainScreenWebView.h"

static NSString *KeyForName = @"name";
static NSString *KeyForBirthday = @"birthday";

@implementation MainScreen {
    
    IBOutlet UIView *onThisDayWebViewPlaceholder;
    IBOutlet UILabel *yourAgeLabel;
    
    IBOutlet UIView *segmentedControlPlaceholder;
    
    AgeDisplaySegmentedControl *ageDisplay;
    MainScreenWebView *onThisDayWebView;
    
    NSDate *birthday;
    NSString *name;

}

@synthesize event;

-(id)init {
    self = [super initWithNibName:@"MainScreen" bundle:[NSBundle mainBundle]];
    
    if (self) {
        name = [Utility_UserInfo currentName];
        birthday = [Utility_UserInfo birthdayForCurrentName];
    }
     
    return self;
}

-(void)getEventForBirthday {
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetEventWithBirthday:birthday];
    AtYourAgeConnection *connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, id result, NSError *error) {
        
        if ([result isKindOfClass:[NSArray class]] && [result count] > 0) {
            self.event = [result objectAtIndex:0];
        } else {
            self.event = result;
        }
        
        [self refresh];
    }];
}

-(void)toggleLabelsHidden {
    
//    ageDisplay.hidden = !ageDisplay.hidden;
//    onThisDayTextView.hidden = !onThisDayTextView.hidden;
}

-(void)configureWebView {
    
 }

-(void)refresh {

    if ([event.eventDescription isEqualToString:@""] || event.eventDescription == nil) {
        [self toggleLabelsHidden];
        //[onThisDayTextView loadHTMLString:@"It looks like nobody in the course of history did anything at your age.  Take a day off!" baseURL:nil];
    } else {
        
        [self toggleLabelsHidden];

        [self configureWebView];
        
        if (ageDisplay == nil) {
            ageDisplay = [[AgeDisplaySegmentedControl alloc] initWithYears:[NSString stringWithFormat:@"%@", event.age_years] months:[NSString stringWithFormat:@"%@", event.age_months] days:[NSString stringWithFormat:@"%@", event.age_days]];
            ageDisplay.frame = segmentedControlPlaceholder.frame;
        } else {
            [ageDisplay updateWithYears:event.age_years months:event.age_months days:event.age_days];
        }
        
        if (onThisDayWebView == nil) {
            onThisDayWebView = [[MainScreenWebView alloc] initWithEvent:event];
            onThisDayWebView.frame = onThisDayWebViewPlaceholder.frame;
            [self.view addSubview:onThisDayWebView];
        } else {
            [onThisDayWebView updateWithEvent:event];
        }
        
        NSLog(@"Frame: %@", NSStringFromCGRect(ageDisplay.frame));
        [self.view addSubview:ageDisplay];
        

        
    }
}

-(void)switchPerson {
    
    SwitchPerson *switchPerson = [[SwitchPerson alloc] init];
    
    [self.navigationController pushViewController:switchPerson animated:YES];
    
}

-(void)setNavigationElements {
    
    self.navigationController.title = name;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(switchPerson)];
    
    self.navigationItem.backBarButtonItem = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    birthday = [Utility_UserInfo birthdayForCurrentName];
    name = [Utility_UserInfo currentName];
    [self getEventForBirthday];
    self.navigationItem.title = name;
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    

    
    [self.navigationController setNavigationBarHidden:NO];
    
    [self setNavigationElements];
}

@end
