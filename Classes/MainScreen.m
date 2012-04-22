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
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        name = [defaults objectForKey:KeyForName];
        birthday = [defaults objectForKey:KeyForBirthday];
        NSLog(@"Birthday: %@", birthday);
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

    NSLog(@"Event: %@", event);
    onThisDayLabel.text = [NSString stringWithFormat:@"On this day in %@'s life...", event.name];
    descriptionLabel.text = event.description;
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

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [self setNavigationElements];
    [self getEventForBirthday];
}

@end
