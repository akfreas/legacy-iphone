#import "LegacyInfoPage.h"
#import "FacebookSignInButton.h"

#import <MessageUI/MessageUI.h>

@implementation LegacyInfoPage {
    
    IBOutlet FacebookSignInButton *facebookButton;
    IBOutlet UILabel *pushNotificationLabel;
    IBOutlet UIButton *sendMailButton;
    IBOutlet UITextView *facebookText;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
    if (self) {
        self.frame = frame;
        pushNotificationLabel.font = [UIFont fontWithName:@"Cinzel-Regular" size:16.0f];
        if ([MFMailComposeViewController canSendMail] == NO) {
            sendMailButton.hidden = YES;
        }
//        [self checkIfPushEnabledAndFlipSwitch];
        [self removeFacebookButtonIfAuthorized];
    }
    return self;
}

//-(void)checkIfPushEnabledAndFlipSwitch {
//    
//    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//    
//    if (types == UIRemoteNotificationTypeNone) {
//        notificationSwitch.on = NO;
//    } else {
//        notificationSwitch.on = YES;
//    }
//    
//}

-(void)removeFacebookButtonIfAuthorized {
    if ([FBSession activeSession].state != FBSessionStateCreatedTokenLoaded) {
        facebookButton.hidden = facebookText.hidden = NO;
    } else {
        facebookButton.hidden = facebookText.hidden = YES;
    }
}


#pragma mark IBActions

-(IBAction)sendMessageButton:(id)sender {
    [Flurry logEvent:@"send_message_button_tapped"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMail" object:nil];
}

-(IBAction)notificationSwitch:(UISwitch *)theSwitch {
    
    if (theSwitch.on == YES) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeNone];
    }
}


#pragma mark FigureRowPageProtocol Delegate Methods

-(void)becameVisible {
    
}

-(void)scrollCompleted {
    
}

@end
