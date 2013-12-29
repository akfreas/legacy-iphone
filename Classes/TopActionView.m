#import "CircleImageView.h"
#import "TopActionView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"

@implementation TopActionView {
    UIButton *addFriendsButton;
    CircleImageView *profilePicButton;
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
        [self addProfilePicButton];
        [self addTitle];
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
    
    addFriendsButton = [[UIButton alloc] initForAutoLayout];
    [addFriendsButton setImage:AddFriendsButtonImage forState:UIControlStateNormal];
    addFriendsButton.tag = 8;
    [addFriendsButton bk_addEventHandler:^(id sender) {
        [AKNOTIF postNotificationName:KeyForFacebookButtonTapped object:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addFriendsButton];
    UIBind(addFriendsButton);
    [self addConstraintWithVisualFormat:@"H:[addFriendsButton]-|" bindings:BBindings];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:addFriendsButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
}

-(void)addProfilePicButton {
    ObjectArchiveAccessor *accessor = [ObjectArchiveAccessor sharedInstance];
    Person *mainPerson = [accessor primaryPerson];
    if (mainPerson != nil && profilePicButton == nil) {
        UIImage *thumb = [UIImage imageWithData:mainPerson.thumbnail];
        profilePicButton = [[CircleImageView alloc] initWithImage:thumb radius:buttonRadii];
        profilePicButton.borderWidth = 0;
        profilePicButton.frame = CGRectMake(TopBarLeftMargin, yButtonOrigin, profilePicButton.frame.size.width, profilePicButton.frame.size.height);
        [self addSubview:profilePicButton];
    }
}

-(void)configureProfilePicButton {
    
    ObjectArchiveAccessor *accessor = [ObjectArchiveAccessor sharedInstance];
    Person *mainPerson = [accessor primaryPerson];
    
    UIImage *thumb = [UIImage imageWithData:mainPerson.thumbnail];

    profilePicButton.image = thumb;
    
}

-(void)setIsVisible:(BOOL)isVisible {
    if (isVisible && profilePicButton.image == nil) {
        [self configureProfilePicButton];
    }
}

-(void)addFriendsButtonTappedAction {
    
    [Flurry logEvent:@"top_action_bar_tapped"];
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForAddFriendButtonTapped object:self];
}

@end
