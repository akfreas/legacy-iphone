@class Event;
@interface EventInfoView : UIView

@property (nonatomic) Event *event;

-(id)initWithEvent:(Event *)anEvent;

@end
