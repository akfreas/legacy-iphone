@class Person;



@interface PersonRow : UIView <UIScrollViewDelegate>

@property (nonatomic) Person *person;
-(void)tapped;
- (id)initWithOrigin:(CGPoint)origin;

@end



@protocol PersonRowDelegate <NSObject>

-(void)personRowWillExpand:(PersonRow *)personRow;

@end