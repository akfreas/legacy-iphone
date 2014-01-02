@class EventPersonRelation;



@interface EventRowHorizontalScrollView : UIScrollView <UIScrollViewDelegate>


@property (nonatomic) EventPersonRelation *relation;
-(void)openDrawer;
-(void)closeDrawer:(void(^)())completion;

@end