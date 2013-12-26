@class EventPersonRelation;

@protocol PageProtocol <NSObject>

@required

-(void)becameVisible;
-(void)scrollCompleted;

@optional

@property (weak, nonatomic) EventPersonRelation *relation;

@end
