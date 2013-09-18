#import "CircleImageView.h"
#import "TopActionView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"

@implementation TopActionView {
    CircleImageView *addFriendsButton;
    CircleImageView *profilePicButton;
    CGFloat buttonRadii;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        buttonRadii = self.bounds.size.height / 2 - 5;
        [self addAddFriendsButton];
        [self addProfilePicButton];
    }
    return self;
}

-(void)addAddFriendsButton {
    
    addFriendsButton = [[CircleImageView alloc] initWithImage:[UIImage imageNamed:@"10-medical.png"] radius:buttonRadii];
    addFriendsButton.frame = CGRectMake(self.frame.size.width - buttonRadii*2 - 5, 5, addFriendsButton.frame.size.height, addFriendsButton.frame.size.width);
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFriendsButtonTappedAction)];
    [addFriendsButton addGestureRecognizer:gesture];
    [self addSubview:addFriendsButton];
}

-(void)addProfilePicButton {
    ObjectArchiveAccessor *accessor = [ObjectArchiveAccessor sharedInstance];
    Person *mainPerson = [accessor primaryPerson];
    UIImage *thumb = [UIImage imageWithData:mainPerson.thumbnail];
    profilePicButton = [[CircleImageView alloc] initWithImage:thumb radius:buttonRadii];
    profilePicButton.frame = CGRectMake(5, 5, profilePicButton.frame.size.width, profilePicButton.frame.size.height);
    [self addSubview:profilePicButton];
}

-(void)addFriendsButtonTappedAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForAddFriendButtonTapped object:self];
}

@end
