#import "LeftRightHostingScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "EventDescriptionView.h"
#import "FigureRow.h"
#import "MainFigureInfoPage.h"
#import "Event.h"
#import "EventPersonRelation.h"
#import "AtYourAgeWebView.h"
#import "BottomFacebookSignInRowView.h"
#import "TopActionView.h"

#import "FigureRowHostingScrollPage.h"

@interface FigureRowHostingScrollPage () <UIScrollViewDelegate>

@end

@implementation FigureRowHostingScrollPage {
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

-(void)addFacebookButton {
    
    BottomFacebookSignInRowView *signInActionRow = [[BottomFacebookSignInRowView alloc] init];
    CGPoint pointForActionRow = [self frameAtIndex:[arrayOfFigureRows count]].origin;
    signInActionRow.frame = CGRectSetOriginOnRect(signInActionRow.frame, pointForActionRow.x, pointForActionRow.y);
    
    [scroller addSubview:signInActionRow];
    scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize, signInActionRow.frame.size.height);
}

-(CGRect)frameAtIndex:(NSInteger)index {
    CGFloat width = self.bounds.size.width;
    
    return CGRectMake(0, (FigureRowPageInitialHeight + EventInfoScrollViewPadding)  * index, width, FigureRowPageInitialHeight);
}

-(NSInteger)indexAtPoint:(CGPoint)point {
    
    NSInteger index = point.x / (FigureRowPageInitialHeight + EventInfoScrollViewPadding);
    return index;
}

-(void)removeInfoViews {
    for (UIView *infoView in arrayOfFigureRows) {
        [infoView removeFromSuperview];
    }
    [arrayOfFigureRows removeAllObjects];
}

-(void)reload {
    
    NSArray *eventArray = [accessor getStoredEventRelations];
    scroller.contentSize = CGSizeMake(self.bounds.size.width, 0);
    for (int i=0; i < [eventArray count]; i++) {
        FigureRow *row;
        EventPersonRelation *relation = [eventArray objectAtIndex:i];
        if (i < [arrayOfFigureRows count] && [arrayOfFigureRows count] > 0) {
            row = [arrayOfFigureRows objectAtIndex:i];
        } else {
            row  = [[FigureRow alloc] initWithOrigin:[self frameAtIndex:i].origin];
            row.event = relation.event;
            row.person = relation.person;
            [arrayOfFigureRows addObject:row];
            [scroller addSubview:row];
        }
        scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize, row.frame.size.height);
    }
    
    if ([[FBSession activeSession] state] != FBSessionStateCreatedTokenLoaded) {
        [self addFacebookButton];
    }
    
    if ([eventArray count] < [arrayOfFigureRows count]) {
        [arrayOfFigureRows removeObjectsInRange:NSMakeRange([eventArray count], [arrayOfFigureRows count] - 1)];
    }
    
    
    
    [self layoutSubviews];
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
