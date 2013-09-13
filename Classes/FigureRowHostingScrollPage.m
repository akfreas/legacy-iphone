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
#import "FacebookSignInButton.h"
#import "TopActionView.h"
#import "AppDelegate.h"

#import "FigureRowHostingScrollPage.h"

@interface FigureRowHostingScrollPage () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

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
    FacebookSignInButton *signInActionRow;
    TopActionView *actionViewTop;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
        priorPoint = CGPointZero;
        accessor = [[ObjectArchiveAccessor alloc] init];
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
    
    return CGRectMake(0, (FigureRowPageInitialHeight + FigureRowScrollViewPadding)  * index + actionViewTopInitialFrame.size.height, width, FigureRowPageInitialHeight);
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
    
    eventArray = [accessor getStoredEventRelations];
    [self removeInfoViews];
    if ([arrayOfFigureRows count] < 1) {
        scroller.contentSize = CGSizeMake(self.bounds.size.width, 0);
    }

    if ([FBSession activeSession].state == FBSessionStateOpen) {
            [self addTopActionView];
    } else {
        [AppDelegate openSessionWithCompletionBlock:^(FBSession *session, FBSessionState state, NSError *error) {
            if (state == FBSessionStateOpen) {
                [self addTopActionView];
            }
        }];
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

-(void)shiftRowsFrameByYValue:(CGFloat)yValue {
    
    for (FigureRow *row in arrayOfFigureRows) {
        row.frame = CGRectSetOriginOnRect(row.frame, row.frame.origin.x, row.frame.origin.y + yValue);
    }
}

-(void)addTopActionView {
    if (actionViewTop == nil) {
        
        actionViewTopInitialFrame = CGRectMake(0, -TopActionViewHeight, self.bounds.size.width, TopActionViewHeight);
        actionViewTop = [[TopActionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, TopActionViewHeight)];
        scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize, actionViewTop.bounds.size.height);
        [self addSubview:actionViewTop];
    }
//    scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize,);
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
    
    if ([actionViewTop superview] == self) {
        [self addTopActionForScrollAction:scrollView];
    }
}

-(void)addTopActionForScrollAction:(UIScrollView *)scrollView {
    
    CGPoint contentOffset = scrollView.contentOffset;
    
    CGFloat diff = priorPoint.y - contentOffset.y;
    
    if (contentOffset.y >= 0 && ((diff > 0 && actionViewTop.frame.origin.y  + diff <= 0) || (diff < 0 && actionViewTop.frame.origin.y >= -actionViewTop.frame.size.height))) {
        actionViewTop.frame = CGRectMake(0, actionViewTop.frame.origin.y + diff, actionViewTop.frame.size.width, actionViewTop.frame.size.height);
    } else if (scrollView.contentOffset.y < 0) {
        actionViewTop.frame = CGRectMake(0, -scrollView.contentOffset.y, actionViewTop.frame.size.width, actionViewTop.frame.size.height);
    }
    
    priorPoint = scrollView.contentOffset;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self resetFrameOnActionViewInScrollView:scrollView];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetFrameOnActionViewInScrollView:scrollView];
}

-(void)resetFrameOnActionViewInScrollView:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y == 0) {
        [self slideDownActionView];
    } else if (actionViewTop.frame.origin.y < -actionViewTop.frame.size.height / 2) {
        [self slideUpActionView];
    } else if (actionViewTop.frame.origin.y >= -actionViewTop.frame.size.height / 2) {
        [self slideDownActionView];
    }
}

-(void)slideUpActionView {
    [UIView animateWithDuration:.2 animations:^{
        actionViewTop.frame = CGRectSetOriginOnRect(actionViewTop.frame, 0, -actionViewTop.frame.size.height);
    }];
}

-(void)slideDownActionView {
    [UIView animateWithDuration:.2 animations:^{
        actionViewTop.frame = CGRectSetOriginOnRect(actionViewTop.frame, 0, 0);
    }];

}

#pragma mark FigureRowPageProtocol Delegate Methods

-(void)becameVisible {
    
}

-(void)scrollCompleted {
}

@end
