#import "FirstTimeLoadScreen.h"
#import "MainScreen.h"
#import "Utility_UserInfo.h"


static NSString *KeyForBirthday = @"birthday";


@implementation FirstTimeLoadScreen {
    
    IBOutlet UIDatePicker *birthdayPicker;
    IBOutlet UITextField *name;
    MainScreen *mainScreen;
}



-(id)init {
    self = [super initWithNibName:@"FirstTimeLoadScreen" bundle:[NSBundle mainBundle]];
    return self;
}



-(IBAction)selectButtonWasTapped {
    [self setInfoAndMoveToNextView];
}

-(void)setInfoAndMoveToNextView {
    
    [Utility_UserInfo setOrUpdateUserBirthday:birthdayPicker.date name:name.text];
    [self moveToNextView];
}

-(void)moveToNextView {
    
    mainScreen = [[MainScreen alloc] init];
    
    [self.navigationController pushViewController:mainScreen animated:YES];
}




@end
