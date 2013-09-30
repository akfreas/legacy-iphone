@class Event;

@interface EventInfoTimelineCell : UITableViewCell

-(id)initWithEvent:(Event *)event;

@property (nonatomic) Event *event;
@property (nonatomic, assign) BOOL showAsKey;

@end
