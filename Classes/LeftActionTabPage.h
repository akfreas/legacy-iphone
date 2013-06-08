#import "PersonRowPageProtocol.h"

@class Person;
@class Event;

@interface LeftActionTabPage : UIView <PersonRowPageProtocol>

@property (nonatomic, assign) CGFloat height;
@property (nonatomic) Person *person;
@property (nonatomic) Event *event;
@property (assign) BOOL shouldHideDelete;

-(id)initWithOrigin:(CGPoint)origin height:(CGFloat)height;

@end
