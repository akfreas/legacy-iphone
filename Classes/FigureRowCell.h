@class EventPersonRelation;
@interface FigureRowCell : UITableViewCell

@property (weak, nonatomic) EventPersonRelation *eventPersonRelation;
@property (nonatomic, readonly) CGFloat height;

-(void)reset;
@end
