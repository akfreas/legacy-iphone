@class Person;



@interface PersonRow : UIView <UIScrollViewDelegate>

@property (nonatomic) Person *person;
+(CGFloat) height;
-(void)tapped;
- (id)initWithOrigin:(CGPoint)origin;

@end



@protocol PersonRowDelegate <NSObject>

-(void)personRowWillExpand:(PersonRow *)personRow;

@end