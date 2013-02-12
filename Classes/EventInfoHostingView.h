@class Event;

@interface EventInfoHostingView : UIViewController <FBFriendPickerDelegate>

@property (strong, nonatomic) Event *event;

-(void)refreshWithPrimaryPerson;

@end
