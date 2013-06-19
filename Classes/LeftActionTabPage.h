#import "FigureRowPageProtocol.h"

@class Person;
@class Event;

@interface LeftActionTabPage : UIView <FigureRowPageProtocol>

@property (nonatomic, assign) CGFloat height;
@property (nonatomic) Person *person;
@property (nonatomic) Event *event;
@property (assign) BOOL shouldHideDelete;

-(id)initWithOrigin:(CGPoint)origin height:(CGFloat)height;

@end
