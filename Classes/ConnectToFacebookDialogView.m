#import "ConnectToFacebookDialogView.h"
#import "FacebookUtils.h"

@implementation ConnectToFacebookDialogView {
    
    UIImageView *checkmarkImage;
    UIButton *okButton;
    UIButton *skipButton;
    UITextView *descriptionTextView;
}

-(CGSize)intrinsicContentSize {
    return CGSizeInset(DefaultFullscreenContentSize, 20, 70);
}

- (id)initForAutoLayout {
    self = [super initForAutoLayout];
    if (self) {
        self.backgroundColor = AppLightBlueColor;
        [self addUIComponents];
    }
    return self;
}

-(void)addUIComponents {
    [self addCheckmarkImage];
    [self addButtons];
    [self addDescriptionLabel];
    [self addLayoutConstraints];
}

-(void)addLayoutConstraints {
    UIBind(checkmarkImage, okButton, skipButton, descriptionTextView);
    NSArray *arr = @[checkmarkImage, descriptionTextView];
    [self addConstraintWithVisualFormat:@"V:|-(>=100)-[checkmarkImage][descriptionTextView(100)]" bindings:BBindings];
    [arr bk_apply:^(UIView *obj) {
        [obj autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
    }];
    [descriptionTextView addConstraintWithVisualFormat:@"H:[descriptionTextView(250)]" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:[skipButton(60)]|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:[okButton(==skipButton)]|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"H:|[okButton][skipButton(==okButton)]|" bindings:BBindings];
    
}

-(void)addCheckmarkImage {
    checkmarkImage = [[UIImageView alloc] initForAutoLayout];
    checkmarkImage.image = CheckMarkImage;
    [self addSubview:checkmarkImage];
}

-(void)addButtons {
    okButton = [[UIButton alloc] initForAutoLayout];
    okButton.backgroundColor = LightButtonColor;
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton bk_addEventHandler:^(id sender) {
        [FacebookUtils loginWithFacebook:^{
            if (self.dismissBlock != NULL) {
                self.dismissBlock();
            }
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:okButton];
    
    skipButton = [[UIButton alloc] initForAutoLayout];
    [skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    skipButton.backgroundColor = DarkButtonColor;
    [skipButton bk_addEventHandler:^(id sender) {
        if (self.dismissBlock != NULL) {
            self.dismissBlock();
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:skipButton];
}

-(void)addDescriptionLabel {
    descriptionTextView = [[UITextView alloc] initForAutoLayout];
    descriptionTextView.text = @"Connecting to Facebook allows you to discover what happened in someone else's life at your friends exact age.";
    descriptionTextView.backgroundColor = [UIColor clearColor];
    descriptionTextView.font = FacebookModalDescriptionFont;
    descriptionTextView.textColor = FacebookModalDescriptionTextColor;
    descriptionTextView.textAlignment = NSTextAlignmentCenter;
    [self addSubview:descriptionTextView];
}

@end
