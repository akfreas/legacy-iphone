@class Person;
@class Event;



@interface FigureRow : UIView <UIScrollViewDelegate>


@property (nonatomic) Event *event;
-(void)tapped;
- (id)initWithOrigin:(CGPoint)origin;

@end



@protocol FigureRowDelegate <NSObject>

-(void)figureRowWillExpand:(FigureRow *)figureRow;

@end