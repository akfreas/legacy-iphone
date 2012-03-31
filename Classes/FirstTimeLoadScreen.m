#import "FirstTimeLoadScreen.h"
#import "MainScreen.h"


static NSString *KeyForBirthday = @"birthday";


@implementation FirstTimeLoadScreen {
    
    IBOutlet UIDatePicker *birthdayPicker;
    MainScreen *mainScreen;
}



-(id)init {
    self = [super initWithNibName:@"FirstTimeLoadScreen" bundle:[NSBundle mainBundle]];
    return self;
}



-(IBAction)selectButtonWasTapped {
    [self setBirthdayAndMoveToNextView];
}

-(void)setBirthdayAndMoveToNextView {
    
    [self setBirthday];
    [self moveToNextView];
}

-(void)setBirthday {
    
    NSDate *birthday = birthdayPicker.date;
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    [defaults setValue:birthday forKey:KeyForBirthday];
}

-(void)moveToNextView {
    
    mainScreen = [[MainScreen alloc] init];
    
    [self.navigationController pushViewController:mainScreen animated:YES];
}




@end
