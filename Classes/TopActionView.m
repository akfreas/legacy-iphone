#import "CircleImageView.h"
#import "TopActionView.h"

@implementation TopActionView {
    CircleImageView *addFriendsButton;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addAddFriendsButton];
    }
    return self;
}

-(void)addAddFriendsButton {
    
    addFriendsButton = [[CircleImageView alloc] initWithImage:[UIImage imageNamed:@"10-medical.png"] radius:self.bounds.size.height / 2 - 5];
    addFriendsButton.frame = CGRectMakeFrameForDeadCenterInRect(self.bounds, addFriendsButton.frame.size);
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFriendsButtonTappedAction)];
    [addFriendsButton addGestureRecognizer:gesture];
    [self addSubview:addFriendsButton];
}

-(void)addFriendsButtonTappedAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForAddFriendButtonTapped object:self];
}

@end
