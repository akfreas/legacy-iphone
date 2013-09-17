@class Person;
@class Event;



@interface FigureRow : UIScrollView <UIScrollViewDelegate>


@property (nonatomic) Event *event;
@property (nonatomic) Person *person;
@property (nonatomic, assign) BOOL selected;
- (id)initWithOrigin:(CGPoint)origin;
-(void)reset;



@end