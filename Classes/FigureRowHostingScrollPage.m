#import "LeftRightHostingScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "EventDescriptionView.h"
#import "FigureRow.h"
#import "Event.h"
#import "EventPersonRelation.h"
#import "LegacyWebView.h"
#import "BottomFacebookSignInRowView.h"
#import "TopActionView.h"

#import "FigureRowHostingScrollPage.h"

@interface FigureRowHostingScrollPage () <UIScrollViewDelegate, NSFetchedResultsControllerDelegate>

@end

@implementation FigureRowHostingScrollPage {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfFigureRows;
    UIScrollView *scroller;
    UIPageControl *pageControl;
    NSMutableArray *pageArray;
    NSArray *eventArray;
    CGPoint priorPoint;
    CGRect actionViewTopInitialFrame; 
    LegacyAppConnection *connection;
    BottomFacebookSignInRowView *signInActionRow;
    TopActionView *actionViewTop;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
        priorPoint = CGPointZero;
        accessor = [ObjectArchiveAccessor sharedInstance];
        pageArray = [NSMutableArray array];
        scroller = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroller.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
        scroller.delegate = self;

        [self addSubview:scroller];
        arrayOfFigureRows = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:KeyForRowDataUpdated object:nil];

    }
    return self;

}


-(CGRect)frameAtIndex:(NSInteger)index {
    CGFloat width = self.bounds.size.width;
    
    return CGRectMake(0, (FigureRowPageInitialHeight + FigureRowScrollViewPadding)  * index + actionViewTop.frame.size.height, width, FigureRowPageInitialHeight);
}

-(NSInteger)indexAtPoint:(CGPoint)point {
    
    NSInteger index = point.x / (FigureRowPageInitialHeight + FigureRowScrollViewPadding);
    return index;
}

-(void)removeInfoViews {
    for (UIView *infoView in arrayOfFigureRows) {
        [infoView removeFromSuperview];
    }
    [arrayOfFigureRows removeAllObjects];
}

-(void)reload {
    
    accessor = [[ObjectArchiveAccessor alloc] init];
    eventArray = [accessor getStoredEventRelations];
    
    if ([arrayOfFigureRows count] < 1) {
        scroller.contentSize = CGSizeMake(self.bounds.size.width, 0);
    }
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        if (actionViewTop == nil) {
            actionViewTopInitialFrame = CGRectMake(0, 0, self.bounds.size.width, 50);
            actionViewTop = [[TopActionView alloc] initWithFrame:actionViewTopInitialFrame];
            scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize, 50);
            [self addSubview:actionViewTop];
        }
    }
    
    for (int i=0; i < [eventArray count]; i++) {
        
        FigureRow *row = [self figureRowForIndex:i];
        if ([row superview] == nil) {
            scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize, row.frame.size.height + FigureRowScrollViewPadding);
            [scroller addSubview:row];
        }
    }

    [self setNeedsLayout];
}

-(FigureRow *)figureRowForIndex:(NSUInteger)index {
    
    FigureRow *row;
    EventPersonRelation *relation = [eventArray objectAtIndex:index];
//    [relation addObserver:self forKeyPath:@"person.thumbnail" options:NSKeyValueObservingOptionNew context:nil];
    if (index < [arrayOfFigureRows count] && [arrayOfFigureRows count] > 0) {
        row = [arrayOfFigureRows objectAtIndex:index];
    } else {
        row  = [[FigureRow alloc] initWithOrigin:[self frameAtIndex:index].origin];
        
        [arrayOfFigureRows addObject:row];
    }
    row.event = relation.event;
    row.person = relation.person;
    return row;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSUInteger index = [eventArray indexOfObject:object];
    if (index != NSNotFound) {

        FigureRow *row = [self figureRowForIndex:index];
        
        if ([object isKindOfClass:[EventPersonRelation class]]) {
            EventPersonRelation *changedObject = (EventPersonRelation *)object;
            row.person = changedObject.person;
            row.event = changedObject.event;
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([[FBSession activeSession] state] != FBSessionStateCreated) {
        [self addTopActionForScrollAction:scrollView];
    }
}

-(void)addTopActionForScrollAction:(UIScrollView *)scrollView {
    
    CGPoint contentOffset = scrollView.contentOffset;
    
    CGFloat diff = priorPoint.y - contentOffset.y;
    
        if (actionViewTop.frame.origin.y <= 0) {
            actionViewTop.frame = CGRectMake(0, actionViewTop.frame.origin.y + diff, actionViewTop.frame.size.width, actionViewTop.frame.size.height);
        } else if (actionViewTop.frame.origin.y > -actionViewTop.frame.size.height) {
            
            actionViewTop.frame = CGRectMake(0, actionViewTop.frame.origin.y + diff, actionViewTop.frame.size.width, actionViewTop.frame.size.height);
        }
    priorPoint = scrollView.contentOffset;
}

#pragma mark FigureRowPageProtocol Delegate Methods

-(void)becameVisible {
    
}

-(void)scrollCompleted {
    
}

@end
