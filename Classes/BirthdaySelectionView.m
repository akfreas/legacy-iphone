#import "BirthdaySelectionView.h"
#import "CircleImageView.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import <SSFlatDatePicker/SSFlatDatePicker.h>

@implementation BirthdaySelectionView {
    
    CircleImageView *profilePhoto;
    UILabel *circleSubtitle;
    UILabel *questionLabel;
    SSFlatDatePicker *birthdayPicker;
    UIButton *saveButton;
    UIButton *cancelButton;
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
    [self addUIComponents];
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
    UIBind(profilePhoto, circleSubtitle, questionLabel, birthdayPicker, saveButton, cancelButton);
    [self addConstraintWithVisualFormat:@"V:|-20-[profilePhoto]-[circleSubtitle]-[questionLabel]-[birthdayPicker][saveButton]" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:[saveButton(60)]|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:[cancelButton(60)]|" bindings:BBindings];
}
-(void)addCircleImage {
    profilePhoto = [[CircleImageView alloc] initWithImage:NoEventImage radius:40.0f];
    profilePhoto.borderWidth = PersonPhotoBorderWidth;
    profilePhoto.borderColor = PersonPhotoBorderColor;
    [self addSubview:profilePhoto];
    UIBind(profilePhoto);
    [self addConstraintWithVisualFormat:@"H:|-[profilePhoto]-|" bindings:BBindings];
    NSURL *profileImageURL = [NSURL URLWithString:_facebookUser[@"picture"][@"data"][@"url"]];
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:profileImageURL options:0 progress:^(NSUInteger receivedSize, long long expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            profilePhoto.image = image;
        });
    }];
    
}

-(void)addLabelBelowCircleImage {
    circleSubtitle = [[UILabel alloc] initForAutoLayout];
    circleSubtitle.text = [NSString stringWithFormat:@"%@ doesn't have their birthday listed on Facebook.", _facebookUser.first_name];
    circleSubtitle.lineBreakMode = NSLineBreakByWordWrapping;
    circleSubtitle.numberOfLines = 3;
    circleSubtitle.textAlignment = NSTextAlignmentCenter;
    circleSubtitle.textColor = HeaderTextColor;
    [self addSubview:circleSubtitle];
    UIBind(circleSubtitle);
    [self addConstraintWithVisualFormat:@"H:[circleSubtitle(200)]" bindings:BBindings];
    [circleSubtitle autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
}

-(void)addQuestionLabel {
    questionLabel = [[UILabel alloc] initForAutoLayout];
    questionLabel.text = [NSString stringWithFormat:@"What is %@'s birthday?", _facebookUser.first_name];
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
    UIBind(birthdayPicker);
    [self addConstraintWithVisualFormat:@"H:|-[birthdayPicker]-|" bindings:BBindings];
}

-(void)addButtons {
    saveButton = [[UIButton alloc] initForAutoLayout];
    [saveButton setTitle:@"OK" forState:UIControlStateNormal];
    [self addSubview:saveButton];
    saveButton.backgroundColor = LightButtonColor;
    
    cancelButton = [[UIButton alloc] initForAutoLayout];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self addSubview:cancelButton];
    cancelButton.backgroundColor = DarkButtonColor;
    UIBind(cancelButton, saveButton);
    [self addConstraintWithVisualFormat:@"H:|[cancelButton][saveButton(==cancelButton)]|" bindings:BBindings];
}

-(CGSize)intrinsicContentSize {
    return DefaultFullscreenContentSize;
}

@end
