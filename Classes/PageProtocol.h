@class Event;

@protocol PageProtocol <NSObject>

@required

-(void)becameVisible;
-(void)scrollCompleted;

@optional

@property (weak, nonatomic) Event *event;

@end
