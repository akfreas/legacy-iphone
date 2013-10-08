#import "RowProtocol.h"
@class Person;
@class Event;



@interface FigureRow : UIScrollView <RowProtocol, UIScrollViewDelegate>


@property (nonatomic) Event *event;
@property (nonatomic) Person *person;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL allowsSelection;
- (id)initWithOrigin:(CGPoint)origin;
-(void)reset;



@end