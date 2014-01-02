@class EventPersonRelation;

@protocol PageProtocol <NSObject>

@required

-(void)becameVisible;
-(void)scrollCompleted;

@optional

@property (strong, nonatomic) EventPersonRelation *relation;

@end
