#import "BirthdaySelectionView.h"
#import "CircleImageView.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import <SSFlatDatePicker/SSFlatDatePicker.h>

@implementation BirthdaySelectionView {
    
    CircleImageView *profilePhoto;
    UILabel *circleSubtitle;
    UILabel *questionLabel;
    SSFlatDatePicker *birthdayPicker;
    UIButton *okButton;
    UIButton *cancelButton;
    BOOL hasLoadedUIComponents;
}

-(id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = AppLightBlueColor;
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

-(void)setFacebookUser:(id<FBGraphUser>)facebookUser {
    _facebookUser = facebookUser;
    if (hasLoadedUIComponents == NO) {
        [self addUIComponents];
        hasLoadedUIComponents = YES;
    }
    [self configureUIComponents];
}

-(void)addUIComponents {
    [self addCircleImage];
    [self addLabelBelowCircleImage];
    [self addQuestionLabel];
    [self addDatePicker];
    [self addButtons];
    [self addVerticalLayoutConstraints];
}

-(void)addVerticalLayoutConstraints {
    UIBind(profilePhoto, circleSubtitle, questionLabel, birthdayPicker, okButton, cancelButton);
    [self addConstraintWithVisualFormat:@"V:|-20-[profilePhoto]-[circleSubtitle]-[questionLabel]-[birthdayPicker]-[okButton]" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:[okButton(60)]|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:[cancelButton(60)]|" bindings:BBindings];
}

-(void)addCircleImage {
    profilePhoto = [[CircleImageView alloc] initWithImage:NoEventImage radius:40.0f];
    profilePhoto.borderWidth = PersonPhotoBorderWidth;
    profilePhoto.borderColor = PersonPhotoBorderColor;
    [self addSubview:profilePhoto];
    UIBind(profilePhoto);
    [self addConstraintWithVisualFormat:@"H:|-[profilePhoto]-|" bindings:BBindings];
    
}

-(void)addLabelBelowCircleImage {
    circleSubtitle = [[UILabel alloc] initForAutoLayout];
    circleSubtitle.lineBreakMode = NSLineBreakByWordWrapping;
    circleSubtitle.numberOfLines = 2;
    circleSubtitle.textAlignment = NSTextAlignmentCenter;
    circleSubtitle.textColor = HeaderTextColor;
    circleSubtitle.font = FacebookModalDescriptionFont;
    [self addSubview:circleSubtitle];
    UIBind(circleSubtitle);
    [self addConstraintWithVisualFormat:@"H:[circleSubtitle(250)]" bindings:BBindings];
    [circleSubtitle autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
}

-(void)addQuestionLabel {
    questionLabel = [[UILabel alloc] initForAutoLayout];
    questionLabel.font = HeaderFont;
    questionLabel.textColor = HeaderTextColor;
    questionLabel.adjustsFontSizeToFitWidth = YES;
    questionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:questionLabel];
    UIBind(questionLabel);
    [self addConstraintWithVisualFormat:@"H:|-[questionLabel]-|" bindings:BBindings];
}

-(void)addDatePicker {
    birthdayPicker = [[SSFlatDatePicker alloc] initForAutoLayout];
    birthdayPicker.datePickerMode = SSFlatDatePickerModeDate;
    [self addSubview:birthdayPicker];
    birthdayPicker.backgroundColor = AppLightBlueColor;
    [[SSFlatDatePicker appearance] setGradientColor:DarkButtonColor];
    UIBind(birthdayPicker);
    [self addConstraintWithVisualFormat:@"H:|-[birthdayPicker]-|" bindings:BBindings];
}

-(void)addButtons {
    okButton = [[UIButton alloc] initForAutoLayout];
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [self addSubview:okButton];
    okButton.backgroundColor = LightButtonColor;
    cancelButton = [[UIButton alloc] initForAutoLayout];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self addSubview:cancelButton];
    cancelButton.backgroundColor = DarkButtonColor;
    
    UIBind(cancelButton, okButton);
    [self addConstraintWithVisualFormat:@"H:|[cancelButton][okButton(==cancelButton)]|" bindings:BBindings];
}

-(void)setOkButtonBlock:(void (^)())okButtonBlock {
    
    _okButtonBlock = okButtonBlock;
    [okButton bk_addEventHandler:^(id sender) {
        if (self.okButtonBlock != NULL) {
            self.okButtonBlock();
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

-(void)setCancelButtonBlock:(void (^)(NSDate *))cancelButtonBlock {
    _cancelButtonBlock = cancelButtonBlock;
    [cancelButton bk_addEventHandler:^(id sender) {
        if (self.cancelButtonBlock != NULL) {
            self.cancelButtonBlock(birthdayPicker.date);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)configureUIComponents {
    
    NSURL *profileImageURL = [NSURL URLWithString:_facebookUser[@"picture"][@"data"][@"url"]];
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:profileImageURL options:0 progress:^(NSUInteger receivedSize, long long expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            profilePhoto.image = image;
        });
    }];
    
    questionLabel.text = [NSString stringWithFormat:@"What is %@'s birthday?", _facebookUser.first_name];
    circleSubtitle.text = [NSString stringWithFormat:@"%@ doesn't have their birthday listed on Facebook.", _facebookUser.first_name];
}

-(CGSize)intrinsicContentSize {
    return DefaultFullscreenContentSize;
}

@end
