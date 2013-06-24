@class Person;
@class Event;



@interface FigureRow : UIView <UIScrollViewDelegate>


@property (nonatomic) Event *event;
@property (nonatomic) Person *person;
- (id)initWithOrigin:(CGPoint)origin;


@end