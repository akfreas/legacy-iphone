@class Event;

@interface EventInfoHostingView_old : UIViewController <FBFriendPickerDelegate>

@property (strong, nonatomic) Event *event;

-(void)refreshWithPrimaryPerson;

@end
