#import "FirstTimeLoadScreen.h"
#import "MainScreen.h"
#import "Utility_UserInfo.h"
#import "BSKeyboardControls.h"


static NSString *KeyForBirthday = @"birthday";


@implementation FirstTimeLoadScreen {
    
    IBOutlet UIDatePicker *birthdayPicker;
    IBOutlet UITextField *name;
    MainScreen *mainScreen;
    BSKeyboardControls *keyboardControls;
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

-(void)placeKeyboardControls {
    
    keyboardControls = [[BSKeyboardControls alloc] init];
    keyboardControls.delegate = self;
    [self.view addSubview:keyboardControls];
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

-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    
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
    
    keyboardControls = [[BSKeyboardControls alloc] init];
    keyboardControls.delegate = self;
    keyboardControls.frame = textFieldAccessoryFrame;
    keyboardControls.alpha = 0.0;

    [self.view addSubview:keyboardControls];
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        keyboardControls.alpha = 1.0;
    }];
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *value = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    
    [value getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        keyboardControls.alpha = 0.0;
    }];
}

-(void)keyboardControlsDonePressed:(BSKeyboardControls *)controls {
    
    [name resignFirstResponder];
    NSLog(@"Done was pressed");
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
}




@end
