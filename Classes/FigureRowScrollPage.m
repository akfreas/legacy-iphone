#import "EventInfoScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "EventDescriptionView.h"
#import "FigureRow.h"
#import "MainFigureInfoPage.h"
#import "Event.h"
#import "AtYourAgeWebView.h"

#import "FigureRowScrollPage.h"

@interface FigureRowScrollPage () <UIScrollViewDelegate>

@end

@implementation FigureRowScrollPage {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfFigureRows;
    NSFetchedResultsController *fetchedResultsController;
    
    UIPageControl *pageControl;
    NSMutableArray *pageArray;
    CGPoint lastPoint;
    AtYourAgeConnection *connection;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.delegate = self;
        lastPoint = CGPointZero;
        accessor = [ObjectArchiveAccessor sharedInstance];
        pageArray = [NSMutableArray array];
        arrayOfFigureRows = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)addInfoViews {
    
    NSArray *eventsInStore = [accessor getStoredEvents];
    
    for (int i=0; i<[eventsInStore count]; i++) {
        
        
        Event *theEvent = [eventsInStore objectAtIndex:i];
        
        __block FigureRow *row = [[FigureRow alloc] initWithOrigin:CGPointMake(0, (FigureRowPageInitialHeight + EventInfoScrollViewPadding) * i)];
        [arrayOfFigureRows addObject:row];
        [self addSubview:row];
        row.event = theEvent;
        
        
        self.contentSize = CGSizeMake(self.contentSize.width, (i + 1) * (FigureRowPageInitialHeight));
    }
    
    [self setNeedsLayout];
}
-(CGRect)frameAtIndex:(NSInteger)index {
    CGFloat padding = 5;
    CGFloat width = Utility_AppSettings.frameForKeyWindow.size.height;
    
    return CGRectMake(0, (FigureRowPageInitialHeight + EventInfoScrollViewPadding)  * index, width, FigureRowPageInitialHeight);
}

-(void)removeInfoViews {
    for (UIView *infoView in arrayOfFigureRows) {
        [infoView removeFromSuperview];
    }
    [arrayOfFigureRows removeAllObjects];
}

-(void)reload {
    [self removeInfoViews];
    [self addInfoViews];
}

@end
