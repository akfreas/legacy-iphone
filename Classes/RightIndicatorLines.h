@class Person;
@interface RightIndicatorLines : UIView


@property (nonatomic) CGPoint lineStartPoint;
@property (nonatomic) CGPoint lineEndPoint;
@property (nonatomic) Person *person;


-(id)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

@end
