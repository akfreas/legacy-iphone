@class EventPersonRelation;
@interface FigureRowCell : UITableViewCell

@property (weak, nonatomic) EventPersonRelation *eventPersonRelation;

-(void)reset;
@end
