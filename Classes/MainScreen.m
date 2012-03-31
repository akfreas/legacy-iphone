#import "MainScreen.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "Event.h"

static NSString *KeyForBirthday = @"birthday";

@implementation MainScreen {
    
    IBOutlet UILabel *yourAgeLabel;
    IBOutlet UILabel *onThisDayLabel;
    IBOutlet UILabel *descriptionLabel;
    
    NSDate *birthday;
    Event *event;
}

-(id)init {
    self = [super initWithNibName:@"MainScreen" bundle:[NSBundle mainBundle]];
    
    if (self) {
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        birthday = [defaults objectForKey:KeyForBirthday];
    }
    
    return self;
}

-(void)getEventForBirthday {
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetEventWithBirthday:birthday];
    AtYourAgeConnection *connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    __block Event *theEvent;
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, id result, NSError *error) {
        theEvent = result;
        [self refresh];
    }];
    
    event = theEvent;
}

-(void)refresh {
    
    
    onThisDayLabel.text = [NSString stringWithFormat:@"On this day in %@'s life...", event.name];
    descriptionLabel.text = event.description;
}

@end
