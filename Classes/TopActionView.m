#import "CircleImageView.h"
#import "TopActionView.h"

#import "Person.h"


@interface ButtonWithImageView : UIButton

@end

@implementation ButtonWithImageView

-(UIView *)viewForBaselineLayout {
    return self.imageView;
}

@end


@implementation TopActionView {
    ButtonWithImageView *addFriendsButton;
    UIButton *backArrowButton;
    CGFloat buttonRadii;
    CGFloat yButtonOrigin;
    UILabel *titleLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        buttonRadii = TopBarButtonRadius;
        self.backgroundColor = HeaderBackgroundColor;
        yButtonOrigin = self.frame.size.height / 2 - TopBarButtonRadius + 5;
        [self addTitle];
        [self addInfoBackButton];
        [self addAddFriendsButton];
    }
    return self;
}

-(void)addTitle {
    titleLabel = [[UILabel alloc] initForAutoLayout];
    titleLabel.text = @"Legacy";
    titleLabel.font = HeaderFont;
    titleLabel.textColor = [UIColor whiteColor];
    MXDictionaryOfVariableBindings(titleLabel);
    [self addSubview:titleLabel];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:8]];
}

-(void)addAddFriendsButton {
    
    addFriendsButton = [[ButtonWithImageView alloc] initForAutoLayout];
    [addFriendsButton setImage:AddFriendsButtonImage forState:UIControlStateNormal];
    addFriendsButton.tag = 8;
    addFriendsButton.contentMode = UIViewContentModeCenter;
    [addFriendsButton bk_addEventHandler:^(id sender) {
        [AKNOTIF postNotificationName:FacebookActionButtonTappedNotificationKey object:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addFriendsButton];
    UIBind(addFriendsButton);
    [self addConstraintWithVisualFormat:@"H:[addFriendsButton(>=70)]|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:|-(<=20)-[addFriendsButton(>=40)]|" bindings:BBindings];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:addFriendsButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    
}

-(void)addInfoBackButton {
    
    backArrowButton = [[ButtonWithImageView alloc] initForAutoLayout];
    [backArrowButton setImage:BackPageButtonImage forState:UIControlStateNormal];
    [backArrowButton bk_addEventHandler:^(id sender) {
        [NotificationUtils scrollToPage:InfoPageNumber];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backArrowButton];
    UIBind(backArrowButton);
    [self addConstraintWithVisualFormat:@"H:|[backArrowButton(>=70)]" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:|-(<=20)-[backArrowButton(>=40)]|" bindings:BBindings];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:backArrowButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
}

-(void)addFriendsButtonTappedAction {
    
    [Flurry logEvent:@"top_action_bar_tapped"];
    [[NSNotificationCenter defaultCenter] postNotificationName:FacebookActionButtonTappedNotificationKey object:self];
}

@end
