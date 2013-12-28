@class Event;

@interface FigureTimelineEventCell : UITableViewCell

-(id)initWithEvent:(Event *)event reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic) Event *event;
@property (nonatomic, assign) BOOL showAsKey;
@property (nonatomic, assign) BOOL isTerminalCell;

@end
