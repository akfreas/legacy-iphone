@class EventPersonRelation;
@interface EventInfoHeaderCell : UITableViewCell

-(id)initWithRelation:(EventPersonRelation *)relation;

@property (readonly) CGPoint pointForLines;
@property (nonatomic, assign) CGFloat nameLabelOriginYOffset;

@end
