#import "LegacyInfoPage.h"
#import "FacebookSignInButton.h"

#import <MessageUI/MessageUI.h>

@interface LegacyInfoPage ()

@property FacebookSignInButton *facebookButton;
@property UIButton *feedbackButton;
@property UILabel *facebookText;
@property UIButton *backButton;
@property UIImageView *logoImage;
@property UILabel *appDescriptionLabel;


@end

@implementation LegacyInfoPage {
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        if ([MFMailComposeViewController canSendMail] == NO) {
            self.feedbackButton.hidden = YES;
        }
//        [self checkIfPushEnabledAndFlipSwitch];
        self.backgroundColor = AppLightBlueColor;
        [self removeFacebookButtonIfAuthorized];
        [self addUIComponents];
    }
    return self;
}

-(void)removeFacebookButtonIfAuthorized {
    if ([FBSession activeSession].state != FBSessionStateCreatedTokenLoaded) {
        self.facebookButton.hidden = self.facebookText.hidden = NO;
    } else {
        self.facebookButton.hidden = self.facebookText.hidden = YES;
    }
}


-(void)addUIComponents {
    [self addBackButton];
    [self addLogoImage];
    [self addAppDescriptionLabel];
    [self addFeedbackButton];
    [self addFacebookTextLabel];
    [self addFacebookButton];
    [self addLayoutConstraints];
}

-(void)addBackButton {
    self.backButton = [[UIButton alloc] initForAutoLayout];
    [self.backButton setImage:CloseButtonImage forState:UIControlStateNormal];
    [self.backButton bk_addEventHandler:^(id sender) {
        [NotificationUtils scrollToPage:LandingPageNumber];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];
}

-(void)addLogoImage {
    self.logoImage = [[UIImageView alloc] initWithImage:LogoImage];
    [self addSubview:self.logoImage];
}

-(void)addAppDescriptionLabel {
    self.appDescriptionLabel = [[UILabel alloc] initForAutoLayout];
    self.appDescriptionLabel.text = @"Discover the past milestones of prominent people in history, entertainment, science, and more.";
    self.appDescriptionLabel.textColor = [UIColor whiteColor];
    self.appDescriptionLabel.font = InfoPageFont;
    self.appDescriptionLabel.numberOfLines = 3;
    [self addSubview:self.appDescriptionLabel];
}

-(void)addFeedbackButton {
    self.feedbackButton = [[UIButton alloc] initForAutoLayout];
    self.feedbackButton.layer.cornerRadius = 8;
    self.feedbackButton.backgroundColor = LightButtonColor;
    self.feedbackButton.titleLabel.font = InfoPageFont;
    [self.feedbackButton setTitle:@"Feedback" forState:UIControlStateNormal];
    [self.feedbackButton bk_addEventHandler:^(id sender) {
        [AnalyticsUtil logPressFromButton:self.feedbackButton];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMail" object:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.feedbackButton];
}

-(void)addFacebookTextLabel {
    self.facebookText = [[UILabel alloc] initForAutoLayout];
    self.facebookText.text = @"We welcome you to connect your Facebook profile to compare your accomplishments to those who left a legacy.";
    self.facebookText.font = InfoPageFont;
    self.facebookText.textColor = [UIColor whiteColor];
    self.facebookText.numberOfLines = 6;
    [self addSubview:self.facebookText];
}

-(void)addFacebookButton {
    self.facebookButton = [[FacebookSignInButton alloc] initForAutoLayout];
    
    [self addSubview:self.facebookButton];
}

-(void)addLayoutConstraints {
    
    NSDictionary *bindingDict = @{@"facebookText" : self.facebookText,
                                  @"backButton" : self.backButton,
                                  @"logoImage" : self.logoImage,
                                  @"appDescriptionLabel" : self.appDescriptionLabel,
                                  @"feedbackButton" : self.feedbackButton,
                                  @"facebookButton" : self.facebookButton};
    for (UIView *v in [bindingDict allValues]) {
        v.translatesAutoresizingMaskIntoConstraints = NO;
    }
    [self addConstraintWithVisualFormat:@"V:|-[backButton(>=70)]-(<=30)-[logoImage]-(<=45)-[appDescriptionLabel]-(15)-[feedbackButton(25)]" bindings:bindingDict];
    [self addConstraintWithVisualFormat:@"H:|[backButton(>=70)]" bindings:bindingDict];
    [self.logoImage autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.appDescriptionLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self addConstraintWithVisualFormat:@"H:|-[appDescriptionLabel]-|" bindings:bindingDict];
    [self addConstraintWithVisualFormat:@"H:|-[feedbackButton(100)]" bindings:bindingDict];
    
        [self addConstraintWithVisualFormat:@"V:[feedbackButton]-(15)-[facebookText]-(>=10)-[facebookButton]-|" bindings:bindingDict];
        [self addConstraintWithVisualFormat:@"H:|-[facebookText]-|" bindings:bindingDict];
        [self addConstraintWithVisualFormat:@"H:|-[facebookButton]-|" bindings:bindingDict];

}


NSDictionary * _AKDictionaryOfVariableBindings(NSString *commaSeparatedKeysString, id firstValue, ...) {
    NSArray *keys = [commaSeparatedKeysString componentsSeparatedByString:@","];
    va_list listPtr;
    va_start(listPtr, [keys count]);
    NSMutableDictionary *dict = [NSMutableDictionary new];
    for (int i=0; i<[keys count]; i++) {
        
    }
    return dict;
}

#pragma mark PageProtocol Delegate Methods

-(void)becameVisible {
    if ([[FBSession activeSession] isOpen] == NO) {
        self.facebookText.hidden = NO;
        self.facebookButton.hidden = NO;
    } else {
        self.facebookText.hidden = YES;
        self.facebookButton.hidden = YES;
    }
}

-(void)scrollCompleted {
    
}

@end
