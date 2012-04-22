#import "MainScreen.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "Event.h"
#import "Utility_UserInfo.h"

static NSString *KeyForName = @"name";

@implementation MainScreen {
    
    IBOutlet UILabel *yourAgeLabel;
    IBOutlet UILabel *onThisDayLabel;
    IBOutlet UILabel *descriptionLabel;
    
    NSDate *birthday;

}

@synthesize event;

-(id)init {
    self = [super initWithNibName:@"MainScreen" bundle:[NSBundle mainBundle]];
    
    if (self) {
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        NSString *name = [defaults objectForKey:KeyForName];
        
        birthday = [Utility_UserInfo getBirthdayForName:name];
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

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self getEventForBirthday];
}

@end
