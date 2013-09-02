#import "LegacyInfoPage.h"

@implementation LegacyInfoPage {
    
    IBOutlet UISwitch *notificationSwitch;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil][0];
    if (self) {
        self.frame = frame;
        [self checkIfPushEnabledAndFlipSwitch];
    }
    return self;
}

-(void)checkIfPushEnabledAndFlipSwitch {
    
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    if (types == UIRemoteNotificationTypeNone) {
        notificationSwitch.on = NO;
    } else {
        notificationSwitch.on = YES;
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
