@class EventPersonRelation;
@interface EventRowCell : UITableViewCell

@property (weak, nonatomic) EventPersonRelation *relation;

-(void)reset;
@end
