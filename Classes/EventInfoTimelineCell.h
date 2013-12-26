@class Event;

@interface EventInfoTimelineCell : UITableViewCell

-(id)initWithEvent:(Event *)event reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic) Event *event;
@property (nonatomic, assign) BOOL showAsKey;

@end
