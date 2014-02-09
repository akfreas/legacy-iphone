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
    [self addConstraintWithVisualFormat:@"H:|-(>=10)-[questionLabel(<=300)]-(>=10)-|" bindings:BBindings];
}

-(void)addDatePicker {
    birthdayPicker = [[SSFlatDatePicker alloc] initForAutoLayout];
    birthdayPicker.datePickerMode = SSFlatDatePickerModeDate;
    [self addSubview:birthdayPicker];
    birthdayPicker.backgroundColor = AppLightBlueColor;
    [[SSFlatDatePicker appearance] setGradientColor:AppLightBlueColor];
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

-(void)setOkButtonBlock:(void (^)(id<FBGraphUser>))okButtonBlock {
    
    _okButtonBlock = okButtonBlock;
    [okButton bk_addEventHandler:^(id sender) {
        if (self.okButtonBlock != NULL) {
            NSString *dateString = [[Utility_AppSettings dateFormatterForDisplay] stringFromDate:birthdayPicker.date];
            [_facebookUser setObject:dateString forKey:@"birthday"];
            self.okButtonBlock(_facebookUser);
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

-(void)setCancelButtonBlock:(void (^)())cancelButtonBlock {
    _cancelButtonBlock = cancelButtonBlock;
    [cancelButton bk_addEventHandler:^(id sender) {
        if (self.cancelButtonBlock != NULL) {
            self.cancelButtonBlock();
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)configureUIComponents {
    profilePhoto.image = NoEventImage;
    NSURL *profileImageURL = [NSURL URLWithString:_facebookUser[@"picture"][@"data"][@"url"]];
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:profileImageURL options:0 progress:^(NSUInteger receivedSize, long long expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            profilePhoto.image = image;
        });
    }];
    questionLabel.adjustsFontSizeToFitWidth = YES;
    questionLabel.text = [NSString stringWithFormat:@"What is %@'s birthday?", _facebookUser.first_name];
    circleSubtitle.text = [NSString stringWithFormat:@"%@ doesn't have their birthday listed on Facebook.", _facebookUser.first_name];
    [self configureBirthdayPickerDate];
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

-(void)configureBirthdayPickerDate {
    NSDate *newBirthday;
    
    if (_facebookUser.birthday != nil) {
        NSArray *stringDateComponents = [_facebookUser.birthday componentsSeparatedByString:@"/"];
        
        NSDateComponents *birthdayComponents = [[NSDateComponents alloc] init];
        NSInteger monthInt = [stringDateComponents[0] integerValue];
        NSInteger dayInt = [stringDateComponents[1] integerValue];
        NSInteger yearInt = 1988;
        if ([stringDateComponents count] == 3) {
            yearInt = [stringDateComponents[2] integerValue];
        }
        [birthdayComponents setMonth:monthInt];
        [birthdayComponents setDay:dayInt];
        [birthdayComponents setYear:yearInt];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

        newBirthday = [calendar dateFromComponents:birthdayComponents];
    } else {
        newBirthday = [NSDate date];
    }
    birthdayPicker.date = newBirthday;
}

-(CGSize)intrinsicContentSize {
    return DefaultFullscreenContentSize;
}

@end
