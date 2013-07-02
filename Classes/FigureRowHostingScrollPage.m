#import "LeftRightHostingScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "EventDescriptionView.h"
#import "FigureRow.h"
#import "MainFigureInfoPage.h"
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideView:) name:KeyForFigureRowContentChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:KeyForRowDataUpdated object:nil];

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
    
    if (signInActionRow == nil) {
        signInActionRow = [[BottomFacebookSignInRowView alloc] init];
        [scroller addSubview:signInActionRow];
    }
    scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize, signInActionRow.frame.size.height);
    CGPoint pointForActionRow = [self frameAtIndex:[arrayOfFigureRows count]].origin;
    signInActionRow.frame = CGRectSetOriginOnRect(signInActionRow.frame, pointForActionRow.x, pointForActionRow.y);
}

-(void)removeFacebookButton {
    [signInActionRow removeFromSuperview];
    scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize, -signInActionRow.frame.size.height);
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
    
    accessor = [[ObjectArchiveAccessor alloc] init];
    eventArray = [accessor getStoredEventRelations];
    scroller.contentSize = CGSizeMake(self.bounds.size.width, 0);
    for (int i=0; i < [eventArray count]; i++) {
        
        FigureRow *row = [self figureRowForIndex:i];
        [scroller addSubview:row];
        scroller.contentSize = CGSizeAddHeightToSize(scroller.contentSize, row.frame.size.height);
    }

    [FBSession openActiveSessionWithAllowLoginUI:NO];
    if ([[FBSession activeSession] state] != FBSessionStateOpen) {
        [self addFacebookButton];
    }
    
//    if ([eventArray count] < [arrayOfFigureRows count]) {
//        [arrayOfFigureRows removeObjectsInRange:NSMakeRange([eventArray count], [arrayOfFigureRows count] - 1)];
//    }
    
    
    
    [self layoutSubviews];
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
    NSLog(@"%@ thumbnail: %@", relation.person.firstName, relation.person.thumbnail);
    return row;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"Keypath: %@ change: %@", keyPath, object);
    
    NSUInteger index = [eventArray indexOfObject:object];
    if (index != NSNotFound) {

        FigureRow *row = [self figureRowForIndex:index];
        
        if ([object isKindOfClass:[EventPersonRelation class]]) {
            EventPersonRelation *changedObject = (EventPersonRelation *)object;
            NSLog(@"Person thumb: %@", changedObject.person.thumbnail);
            row.person = changedObject.person;
            row.event = changedObject.event;
        }
    }
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
