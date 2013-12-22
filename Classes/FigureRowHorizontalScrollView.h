#import "RowProtocol.h"
@class Person;
@class Event;



@interface FigureRowHorizontalScrollView : UIScrollView <RowProtocol, UIScrollViewDelegate>


@property (nonatomic) Event *event;
@property (nonatomic) Person *person;
-(void)delayedReset;
-(void)openDrawer;
-(void)closeDrawer:(void(^)())completion;

@end