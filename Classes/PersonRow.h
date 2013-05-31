@class Person;



@interface PersonRow : UIView <UIScrollViewDelegate>

@property (nonatomic) Person *person;
-(void)tapped;

@end



@protocol PersonRowDelegate <NSObject>

-(void)personRowWillExpand:(PersonRow *)personRow;

@end