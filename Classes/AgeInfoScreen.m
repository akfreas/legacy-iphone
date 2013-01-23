#import "AgeInfoScreen.h"
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

@implementation AgeInfoScreen {
    
    IBOutlet UIView *onThisDayWebViewPlaceholder;
    IBOutlet UILabel *yourAgeLabel;
    
    IBOutlet UIView *segmentedControlPlaceholder;
    IBOutlet UIView *borderView;
    
    AgeDisplaySegmentedControl *ageDisplay;
    AgeArticleView *articleView;
    User *currentUser;
    ObjectArchiveAccessor *accessor;
    
    UINavigationController *viewForSettings;
}

@synthesize event;

-(id)init {
    self = [super initWithNibName:@"AgeInfoScreen" bundle:[NSBundle mainBundle]];
    
    if (self) {
        accessor = [[ObjectArchiveAccessor alloc] init];
        currentUser = [accessor primaryUser];
    }
    
    return self;
}

-(void)getEventForBirthday {
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetEventForUser:currentUser];
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
    ageDisplay.hidden = YES;
}

-(void)refresh {
    
    if ([event.eventDescription isEqualToString:@""] || event.eventDescription == nil) {
        [self toggleLabelsHidden];
    } else {
        
        if (ageDisplay == nil) {
            ageDisplay = [[AgeDisplaySegmentedControl alloc] initWithYears:[NSString stringWithFormat:@"%@", event.age_years] months:[NSString stringWithFormat:@"%@", event.age_months] days:[NSString stringWithFormat:@"%@", event.age_days]];
            ageDisplay.frame = segmentedControlPlaceholder.frame;
        } else {
            [ageDisplay updateWithYears:event.age_years months:event.age_months days:event.age_days];
        }
        
        [articleView updateWithUser:currentUser];
        
        
        NSLog(@"Frame: %@", NSStringFromCGRect(ageDisplay.frame));
        [self.view addSubview:ageDisplay];
        
        
        
    }
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    currentUser = [accessor primaryUser];
    
    self.navigationItem.title = currentUser.firstName;
    [self getEventForBirthday];
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    [borderView.layer setCornerRadius:10.0];
    
    [self.navigationController setNavigationBarHidden:NO];
    
}

@end
