#import "LegacyInfoPage.h"
#import "FacebookSignInButton.h"

@implementation LegacyInfoPage {
    
    IBOutlet FacebookSignInButton *facebookButton;
    IBOutlet UILabel *pushNotificationLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil][0];
    if (self) {
        self.frame = frame;
        pushNotificationLabel.font = [UIFont fontWithName:@"Cinzel-Regular" size:16.0f];
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
        facebookButton.hidden = NO;
    } else {
        facebookButton.hidden = YES;
    }
}

#pragma mark IBActions

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
