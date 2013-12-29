#import "EventRowDrawerOpenBucket.h"
#import "EventRowHorizontalScrollView.h"

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
    }
    return self;
}

-(void)addRow:(__weak EventRowHorizontalScrollView *)cell {
    if (cell != nil) {
        [self.arrayOfCells addObject:cell];
    }
}

-(void)closeDrawers:(void (^)())completion {
    for (EventRowHorizontalScrollView *view in self.arrayOfCells) {
        if (view != nil) {
            [view closeDrawer:NULL];
        }
    }
    [self.arrayOfCells removeAllObjects];
    if (completion != NULL) {
        completion();
    }
}

@end
