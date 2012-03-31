#import "FirstTimeLoadScreen.h"


static NSString *KeyForBirthday = @"birthday";


@implementation FirstTimeLoadScreen {
    
    IBOutlet UIDatePicker *birthdayPicker;
}



-(id)init {
    self = [super initWithNibName:@"FirstTimeLoadScreen" bundle:[NSBundle mainBundle]];
    return self;
}



-(IBAction)selectButtonWasTapped {
    
}

-(void)setBirthdayAndMoveToNextView {
    
    NSDate *birthday = birthdayPicker.date;
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    
    [defaults setValue:birthday forKey:KeyForBirthday];
    

}

-(void)moveToNextView {
    
    
}




@end
