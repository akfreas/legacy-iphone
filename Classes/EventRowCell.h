@class EventPersonRelation;
@interface EventRowCell : UITableViewCell

@property (weak, nonatomic) EventPersonRelation *eventPersonRelation;

-(void)reset;
@end
