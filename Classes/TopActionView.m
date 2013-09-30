#import "CircleImageView.h"
#import "TopActionView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"

@implementation TopActionView {
    CircleImageView *addFriendsButton;
    CircleImageView *profilePicButton;
    UIToolbar *toolBar;
    CGFloat buttonRadii;
    UIImageView *headerImage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        buttonRadii = 20;
        toolBar = [[UIToolbar alloc] initWithFrame:self.bounds];
        [self.layer insertSublayer:toolBar.layer atIndex:0];
        if ([toolBar respondsToSelector:@selector(setBarTintColor:)]) {
            [toolBar setBarTintColor:[UIColor colorWithWhite:1 alpha:.85]];
        } else {
            toolBar.alpha = 0.96f;
            toolBar.tintColor = [UIColor whiteColor];
        }
        [self addAddFriendsButton];
        [self addProfilePicButton];
        [self addHeaderTextImage];
    }
    return self;
}

-(void)addHeaderTextImage {
    
    headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"legacy-header-text.png"]];
    headerImage.frame = CGRectMakeFrameForDeadCenterInRect(self.frame, headerImage.bounds.size);
    [self addSubview:headerImage];
}

-(void)addAddFriendsButton {
    
    addFriendsButton = [[CircleImageView alloc] initWithImage:[UIImage imageNamed:@"add-friends-button.png"] radius:buttonRadii];
    addFriendsButton.frame = CGRectMake(self.frame.size.width - buttonRadii*2 - 15, 15, addFriendsButton.frame.size.height, addFriendsButton.frame.size.width);
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFriendsButtonTappedAction)];
    [addFriendsButton addGestureRecognizer:gesture];
    [self addSubview:addFriendsButton];
}

-(void)addProfilePicButton {
    ObjectArchiveAccessor *accessor = [ObjectArchiveAccessor sharedInstance];
    Person *mainPerson = [accessor primaryPerson];
    if (mainPerson != nil && profilePicButton == nil) {
        UIImage *thumb = [UIImage imageWithData:mainPerson.thumbnail];
        profilePicButton = [[CircleImageView alloc] initWithImage:thumb radius:buttonRadii];
        profilePicButton.borderWidth = 0;
        profilePicButton.frame = CGRectMake(15, 15, profilePicButton.frame.size.width, profilePicButton.frame.size.height);
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
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForAddFriendButtonTapped object:self];
}

@end
