#import "RowProtocol.h"
@class EventPersonRelation;



@interface FigureRowHorizontalScrollView : UIScrollView <RowProtocol, UIScrollViewDelegate>


@property (nonatomic) EventPersonRelation *relation;
-(void)delayedReset;
-(void)openDrawer;
-(void)closeDrawer:(void(^)())completion;

@end