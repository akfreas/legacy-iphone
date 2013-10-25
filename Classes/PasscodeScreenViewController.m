#import "LegacyAppConnection.h"
#import "LegacyAppRequest.h"
#import "PasscodeScreenViewController.h"
#import "AFAlertView.h"

@interface PasscodeScreenViewController () <UITextFieldDelegate>

@end

@implementation PasscodeScreenViewController {
    
    IBOutlet UITextField *passcodeTextField;
}

-(id)init {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self beginPasscodeVerification];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [passcodeTextField becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)beginPasscodeVerification {
    
    LegacyAppRequest *request = [LegacyAppRequest requestToVerifyPasscode:passcodeTextField.text];
    LegacyAppConnection *connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
    [connection getWithCompletionBlock:^(LegacyAppRequest *request, NSDictionary *result, NSError *error) {
        if (error == nil && [result[@"verification_status"] isEqualToString:@"success"]) {
            [self passcodeVerifictionSuccess:result[@"message"]];
        } else if (error == nil) {
            [self passcodeVerificationFailure:result[@"message"]];
        } else {
            
        }
    }];
}

-(void)showServerError:(NSError *)error {
    
    AFAlertView *alert = [[AFAlertView alloc]  initWithTitle:@"Server error"];
    
    alert.description = @"There was an error processing your request.  We are working on fixing this ASAP, please try again later!";
    alert.leftButtonTitle = @"OK";
    [alert showInView:self.view];
}

-(void)passcodeVerifictionSuccess:(NSString *)message {
    AFAlertView *alert = [[AFAlertView alloc] initWithTitle:@"You're in!"];
    alert.description = message;
    
    alert.leftButtonActionBlock = ^(NSArray *ui){
        [self dismissViewControllerAnimated:YES completion:NULL];
    };
    alert.leftButtonTitle = @"OK!";
    
    [alert showInView:self.view];
}

-(void)passcodeVerificationFailure:(NSString *)message {
    
    AFAlertView *alert = [[AFAlertView alloc] initWithTitle:@"Couldn't Verify Passcode"];
    if (message != nil) {
        alert.description = message;
    } else {
        alert.description = @"We're sorry, we couldn't verify your passcode at this time.  Check with the person who gave you the passcode to see if you're on our list.  Thanks!";
            
    }

    alert.leftButtonTitle = @"OK";
    
    [alert showInView:self.view];
    
}

@end
