#import "MainScreen.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "Event.h"
#import "Utility_UserInfo.h"
#import "SwitchPerson.h"

static NSString *KeyForName = @"name";
static NSString *KeyForBirthday = @"birthday";

@implementation MainScreen {
    
    IBOutlet UILabel *yourAgeLabel;
    IBOutlet UILabel *onThisDayLabel;
    IBOutlet UILabel *descriptionLabel;
    
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
        self.event = result;
        [self refresh];
    }];
}

-(void)refresh {

    if ([event.eventDescription isEqualToString:@""] || event.eventDescription == nil) {
        yourAgeLabel.hidden = YES;
        descriptionLabel.hidden = YES;
        onThisDayLabel.text = @"It looks like nobody in the course of history did anything at your age.  Take a day off!";
    } else {
        yourAgeLabel.hidden = NO;
        descriptionLabel.hidden = NO;
        
        NSLog(@"Event: %@", event.eventDescription);
        onThisDayLabel.text = [NSString stringWithFormat:@"On this day in %@'s life...", event.name];
        
        yourAgeLabel.text = [NSString stringWithFormat:@"You are %@ years, %@ months, and %@ days old.", event.age_years, event.age_months, event.age_days];
        
        descriptionLabel.text = event.eventDescription;
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
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [self setNavigationElements];
}

@end
