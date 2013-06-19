@class Person;



@interface FigureRow : UIView <UIScrollViewDelegate>

@property (nonatomic) Person *person;
-(void)tapped;
- (id)initWithOrigin:(CGPoint)origin;

@end



@protocol FigureRowDelegate <NSObject>

-(void)figureRowWillExpand:(FigureRow *)figureRow;

@end