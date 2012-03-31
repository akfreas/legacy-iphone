#import "MainScreen.h"
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
    
}

@end
