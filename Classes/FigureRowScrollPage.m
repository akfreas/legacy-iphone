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
#import "BottomFacebookSignInRowView.h"
#import "TopActionView.h"

#import "FigureRowScrollPage.h"

@interface FigureRowScrollPage () <UIScrollViewDelegate>

@end

@implementation FigureRowScrollPage {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfFigureRows;
    NSFetchedResultsController *fetchedResultsController;
    UIScrollView *scroller;
    UIPageControl *pageControl;
    NSMutableArray *pageArray;
    CGPoint priorPoint;
    AtYourAgeConnection *connection;
    TopActionView *actionViewTop;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        priorPoint = CGPointZero;
        accessor = [ObjectArchiveAccessor sharedInstance];
        pageArray = [NSMutableArray array];
        scroller = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroller.delegate = self;
        [self addSubview:scroller];
        arrayOfFigureRows = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideView:) name:KeyForFigureRowContentChanged object:nil];
    }
    return self;
}

-(void)hideView:(NSNotification *)notif {
    
    NSDictionary *userInfo = notif.userInfo;
    UIView *theView = notif.object;
    CGFloat animationDuration = [userInfo[@"animation_duration"] floatValue];
    CGSize sizeChange = [userInfo[@"size_change"] CGSizeValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        scroller.contentSize = CGSizeAddSizeToSize(scroller.contentSize, sizeChange);
        theView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [theView removeFromSuperview];
        }
    }];
}


-(void)addInfoViews {
    
    NSArray *eventsInStore = [accessor getStoredEvents];
    
    for (int i=0; i<[eventsInStore count]; i++) {
        
        
        Event *theEvent = [eventsInStore objectAtIndex:i];
        
        __block FigureRow *row = [[FigureRow alloc] initWithOrigin:[self frameAtIndex:i].origin];
        [arrayOfFigureRows addObject:row];
        [scroller addSubview:row];
        row.event = theEvent;
        
        
        scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize, FigureRowPageInitialHeight);
    }
//    
    if ([[FBSession activeSession] state] != FBSessionStateCreatedTokenLoaded) {
                [self addFacebookButton];
        }
    
    [self setNeedsLayout];
}

-(void)addFacebookButton {
    
    BottomFacebookSignInRowView *signInActionRow = [[BottomFacebookSignInRowView alloc] init];
    CGPoint pointForActionRow = [self frameAtIndex:[arrayOfFigureRows count]].origin;
    signInActionRow.frame = CGRectSetOriginOnRect(signInActionRow.frame, pointForActionRow.x, pointForActionRow.y);
    
    [scroller addSubview:signInActionRow];
    [arrayOfFigureRows addObject:signInActionRow];
    scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize, signInActionRow.frame.size.height);
}

-(CGRect)frameAtIndex:(NSInteger)index {
    CGFloat width = self.bounds.size.width;
    
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self addTopActionForScrollAction:scrollView];
}

-(void)addTopActionForScrollAction:(UIScrollView *)scrollView {
    if (actionViewTop == nil) {
        CGFloat height = 30;
        actionViewTop = [[TopActionView alloc] initWithFrame:CGRectMake(0, -height, self.bounds.size.width, height)];
        [self addSubview:actionViewTop];
        priorPoint = scrollView.contentOffset;
    }
    
    if (priorPoint.y > scrollView.contentOffset.y) {
        [UIView animateWithDuration:0.1 animations:^{
            actionViewTop.frame = CGRectSetOriginOnRect(actionViewTop.frame, 0, 0);
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            actionViewTop.frame = CGRectSetOriginOnRect(actionViewTop.frame, 0, -actionViewTop.frame.size.height);
        }];
    }
    priorPoint = scrollView.contentOffset;
}

@end
