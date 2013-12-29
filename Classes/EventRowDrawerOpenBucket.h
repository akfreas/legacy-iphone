@class EventRowHorizontalScrollView;
@interface EventRowDrawerOpenBucket : NSObject

@property (strong, nonatomic) NSMutableArray *arrayOfCells;

+(EventRowDrawerOpenBucket *)sharedInstance;
+(BOOL)hasOpenDrawers;
-(void)closeDrawers:(void(^)())completion;
-(void)addRow:(__weak EventRowHorizontalScrollView *)cell;

@end
