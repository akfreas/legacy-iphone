@class Person;
@interface PersonRow : UIView <UIScrollViewDelegate>

@property (nonatomic) Person *person;
-(void)tapped;

@end
