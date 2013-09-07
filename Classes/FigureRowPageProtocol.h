@class Event;

@protocol FigureRowPageProtocol <NSObject>

@required

-(void)becameVisible;
-(void)scrollCompleted;

@optional

@property (weak, nonatomic) Event *event;

@end
