@class EventPersonRelation;
@interface FigureTimelineTopCell : UITableViewCell

-(id)initWithRelation:(EventPersonRelation *)relation;

@property (readonly) CGPoint pointForLines;
@property (nonatomic, assign) CGFloat nameLabelOriginYOffset;

@end
