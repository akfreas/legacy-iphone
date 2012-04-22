#import "AddNewPerson.h"
#import "Utility_UserInfo.h"
#import "BSKeyboardControls.h"

@implementation AddNewPerson {
    
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UITextField *name;
    BSKeyboardControls *keyboardControls;

}

-(id)init {
    self = [super initWithNibName:@"AddNewName" bundle:[NSBundle bundleForClass:[self class]]];
    return self;
}


-(void)configureNavigationItems {
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWasTapped)];
    
    self.navigationItem.title = @"Add Another Person";
}

-(void)doneWasTapped {
    
    if ([name.text isEqualToString:@""] || [datePicker.date timeIntervalSinceNow] > 0) {
        [self displayValidationAlerts];
    } else {
            
        [Utility_UserInfo setOrUpdateUserBirthday:datePicker.date name:name.text];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)placeKeyboardControls {
    
    keyboardControls = [[BSKeyboardControls alloc] init];
    keyboardControls.delegate = self;
    keyboardControls.alpha = 0.0;
    keyboardControls.frame = CGRectMake(0, 480, 320, 44);
    
    [self.view addSubview:keyboardControls];
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
    
    CGRect textFieldAccessoryFrame = [self.view convertRect:CGRectMake(0, self.view.frame.size.height - keyboardTop + 5, 320, 44) toView:nil] ;
    
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

-(void)displayValidationAlerts {
    
    NSString *alertText;
    
    if ([name.text isEqualToString:@""] && [datePicker.date timeIntervalSinceNow] > 0) {
        alertText = @"Please enter a name.";
    } else if ([name.text isEqualToString:@""] || [datePicker.date timeIntervalSinceNow] > 0) {
        alertText = @"Please enter a valid date and a name.";
    } else if ([datePicker.date timeIntervalSinceNow] > 0) {
        alertText = @"Please enter a valid date.";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertText delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alert show];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    [self registerForKeyboardNotifications];
    [self placeKeyboardControls];
    [self configureNavigationItems];
}

@end
