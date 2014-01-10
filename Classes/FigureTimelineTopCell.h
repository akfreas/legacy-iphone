@class EventPersonRelation;
@interface FigureTimelineTopCell : UITableViewCell

@property (readonly) CGPoint pointForLines;
@property (nonatomic, assign) CGFloat nameLabelOriginYOffset;
@property (nonatomic, strong) EventPersonRelation *relation;
@end
