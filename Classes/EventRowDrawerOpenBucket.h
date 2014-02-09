@class EventRowHorizontalScrollView;
@interface EventRowDrawerOpenBucket : NSObject

@property (strong, atomic) NSMutableArray *arrayOfCells;

+(EventRowDrawerOpenBucket *)sharedInstance;
+(BOOL)hasOpenDrawers;
-(void)closeDrawers:(void(^)())completion;
-(void)addRow:(__weak EventRowHorizontalScrollView *)cell;
-(void)removeRow:(EventRowHorizontalScrollView *)cell;

@end
