#import "FirstTimeLoadScreen.h"
#import "MainScreen.h"
#import "Utility_PersonInfo.h"
#import "BSKeyboardControls.h"


static NSString *KeyForBirthday = @"birthday";
static NSString *KeyForName = @"name";


@implementation FirstTimeLoadScreen {
    
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
        
//    [Utility_PersonInfo setCurrentName:name.text];
//    [Utility_PersonInfo setOrUpdatePersonBirthday:birthdayPicker.date name:name.text];
    [self moveToNextView];
}

-(void)moveToNextView {
    
    mainScreen = [[MainScreen alloc] init];
    
    [self.navigationController pushViewController:mainScreen animated:YES];
}

-(void)registerForKeyboardNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;    
    keyboardRect = [value CGRectValue];

    keyboardRect = [self.view convertRect:keyboardRect toView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    CGRect textFieldAccessoryFrame = CGRectMake(0, keyboardTop - 80, 320, 44);
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    
    [animationDurationValue getValue:&animationDuration];
    

    
    [UIView animateWithDuration:animationDuration animations:^{
        keyboardControls.frame = textFieldAccessoryFrame;
        keyboardControls.alpha = 1.0;
    }];
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *value = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    
    [value getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        keyboardControls.frame = CGRectMake(0, 480, 320, 44);
        keyboardControls.alpha = 0.0;
    }];
}

-(void)keyboardControlsDonePressed:(BSKeyboardControls *)controls {
    [name resignFirstResponder];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self placeKeyboardControls];
    [self registerForKeyboardNotifications];
}




@end
