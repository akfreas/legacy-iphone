#import "EventRowDrawerOpenBucket.h"
#import "EventRowHorizontalScrollView.h"

@interface EventRowDrawerOpenBucket ()
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation EventRowDrawerOpenBucket

+(EventRowDrawerOpenBucket *)sharedInstance {
    static dispatch_once_t onceToken;
    static EventRowDrawerOpenBucket *bucket;
    dispatch_once(&onceToken, ^{
        if (bucket == nil) {
            bucket = [EventRowDrawerOpenBucket new];
        }
    });
    return bucket;
}

+(BOOL)hasOpenDrawers {
    return [[[self sharedInstance] arrayOfCells] count] > 0;
}

-(id)init {
    self = [super init];
    if (self) {
        self.arrayOfCells = [NSMutableArray array];
        self.queue = dispatch_queue_create("com.sashimiblade.legacyapp.draweroperation", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void)addRow:(__weak EventRowHorizontalScrollView *)cell {
    if (cell != nil) {
        dispatch_async(self.queue, ^{
            [self.arrayOfCells addObject:cell];
        });
    }
}

-(void)removeRow:(EventRowHorizontalScrollView *)cell {
    dispatch_async(self.queue, ^{
        [self.arrayOfCells removeObject:cell];
    });
}

-(void)closeDrawers:(void (^)())completion {
    
    dispatch_sync(self.queue, ^{
        
        for (EventRowHorizontalScrollView *view in self.arrayOfCells) {
            if (view != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [view closeDrawer:NULL];
                });
            }
        }
        [self.arrayOfCells removeAllObjects];
    });
    
    if (completion != NULL) {
        completion();
    }
}

@end
