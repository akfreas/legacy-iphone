@class Event;
@interface EventInfoHeaderCell : UITableViewCell

-(id)initWithEvent:(Event *)anEvent;

@property (readonly) CGPoint pointForLines;
@property (nonatomic, assign) CGFloat nameLabelOriginYOffset;

@end
