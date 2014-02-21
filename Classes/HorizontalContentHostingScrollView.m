#import "HorizontalContentHostingScrollView.h"
#import "Person.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "EventRowHorizontalScrollView.h"
#import "Event.h"
#import "EventPersonRelation.h"
#import "LegacyWebView.h"
#import "EventTablePage.h"
#import "FigureTimelinePage.h"
#import "LegacyInfoPage.h"
#import "EventRowDrawerOpenBucket.h"

@interface HorizontalContentHostingScrollView () <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL scrollingFromTouch;

@end

typedef enum ScrollViewDirection {
    ScrollViewDirectionRight,
    ScrollViewDirectionLeft,
} ScrollViewDirection;

@implementation HorizontalContentHostingScrollView {
    NSFetchedResultsController *fetchedResultsController;
    
    NSInteger currentPage;
    NSMutableArray *pageArray;
    EventTablePage *figurePage;
    CGPoint departurePoint;
    CGPoint destinationPoint;
    CGPoint lastScrollPoint;
    BOOL paginationInProgress;
    LegacyAppConnection *connection;
    ScrollViewDirection direction;
    FigureTimelinePage *timelinePage;
}

+(BOOL)requiresConstraintBasedLayout {
    return YES;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bounces = NO;
        departurePoint = CGPointZero;
        self.contentSize = CGSizeMake(0, self.bounds.size.height);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEventInfoPageAndScroll:) name:EventRowTappedNotificationKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToPageWithNotif:) name:KeyForScrollToPageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToLandingPage) name:KeyForLoggedIntoFacebookNotification object:nil];
        timelinePage = [[FigureTimelinePage alloc] init];
        [self addLegacyInfoPage];
        [self addFigurePage];
        [self scrollToPage:LandingPageNumber];
    }
    return self;
}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(320, 480);
}

-(void)scrollToInfoPage {
    [self scrollToPage:InfoPageNumber];
}

-(void)scrollToLandingPage {
    [self scrollToPage:LandingPageNumber];
}

-(void)addFigurePage {
    
    figurePage = [[EventTablePage alloc] initWithFrame:[self frameAtIndex:LandingPageNumber]];
    [self addPage:figurePage];
}

-(void)addLegacyInfoPage {
    
    LegacyInfoPage *infoPage = [[LegacyInfoPage alloc] initWithFrame:[self frameAtIndex:InfoPageNumber]];
    [self addPage:infoPage];
}

-(void)addPage:(UIView <PageProtocol> *)page {
    if (pageArray == nil) {
        pageArray = [NSMutableArray array];
    }
    [pageArray addObject:page];
    page.frame = [self frameAtIndex:[pageArray count] - 1];
    [self addSubview:page];
    self.contentSize = CGSizeAddWidthToSize(self.contentSize, page.frame.size.width + SpaceBetweenFigureRowPages);
    
}


-(void)removePage:(UIView <PageProtocol> *)page {
    
    [page removeFromSuperview];
    [pageArray removeObject:page];
    
    CGSize newContentSize = CGSizeMake(0, self.bounds.size.height);
    
    for (UIView <PageProtocol> *thePage in pageArray) {
        CGSize pageSize = thePage.frame.size;
        newContentSize = CGSizeAddWidthToSize(newContentSize, pageSize.width + SpaceBetweenFigureRowPages);
    }
    self.contentSize = newContentSize;
    
}

-(void)addEventInfoPageAndScroll:(NSNotification *)notif {
    
    [[EventRowDrawerOpenBucket sharedInstance] closeDrawers:NULL];
    NSDictionary *userInfo = notif.userInfo;
    EventPersonRelation *relation = userInfo[@"relation"];
    timelinePage.relation = relation;
    timelinePage.frame = [self frameAtIndex:TimelinePageNumber];
    [timelinePage reloadData];
    [self addPage:timelinePage];
    [self scrollToPage:TimelinePageNumber];
}

-(CGRect)frameAtIndex:(NSInteger)index {
    
    CGRect windowFrame = [[[[UIApplication sharedApplication] windows] lastObject] frame];
    return CGRectMake((self.bounds.size.width + SpaceBetweenFigureRowPages) * index , 0, self.bounds.size.width, windowFrame.size.height);
}

-(void)checkIfScrollCompletedAndNotifyPage {
    
    if (CGPointEqualToPoint(self.contentOffset, destinationPoint)) {
        paginationInProgress = NO;
        self.scrollEnabled = YES;
        UIView <PageProtocol> *page = [pageArray objectAtIndex:currentPage];
        
        if ([page isKindOfClass:[FigureTimelinePage class]] && currentPage == [pageArray count] - 1) {
            
            LegacyWebView *webView = [[LegacyWebView alloc] initWithFrame:[self frameAtIndex:WebViewPageNumber]];
            webView.frame = CGRectSetHeightForRect(self.bounds.size.height, webView.frame);
            webView.relation = page.relation;
            [self addPage:webView];
        }
        
        [page scrollCompleted];
    }
}


-(void)notifyVisiblePage {
    
    CGPoint referencePoint;
    if (direction == ScrollViewDirectionLeft) {
        referencePoint = CGPointMake(self.contentOffset.x + self.bounds.size.width, 0);
    } else {
        referencePoint = self.contentOffset;
    }
    
    NSInteger pageIndex = [self pageAtPoint:referencePoint];
    if (pageIndex < [pageArray count]) {
        UIView <PageProtocol> *page = pageArray[pageIndex];
        [page becameVisible];
    }
    
}

-(NSInteger)pageAtPoint:(CGPoint)point {
    NSInteger pageIndex = floor(point.x / (self.bounds.size.width + SpaceBetweenFigureRowPages));
    return pageIndex;
}

-(void)setScrollViewDirection {
    
    if (self.contentOffset.x > lastScrollPoint.x) {
        direction = ScrollViewDirectionLeft;
    } else {
        direction = ScrollViewDirectionRight;
    }
    lastScrollPoint = self.contentOffset;
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self paginateScrollView:scrollView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self checkIfScrollCompletedAndNotifyPage];
    [self setScrollViewDirection];
    if (scrollView.contentOffset.x < [self frameAtIndex:LandingPageNumber].origin.x && self.scrollingFromTouch == YES) {
        scrollView.contentOffset = [self frameAtIndex:currentPage].origin;
        return;
    }
    [self notifyVisiblePage];
    if (scrollView.contentOffset.x == [self frameAtIndex:LandingPageNumber].origin.x && [pageArray count] > 0) {
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:pageArray];
        for (int i=LandingPageNumber + 1; i < [newArray count]; i++) {
            
            UIView <PageProtocol> *page = [newArray objectAtIndex:i];
            [self removePage:page];
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == YES) {
        [self paginateScrollView:scrollView];
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self paginateScrollView:scrollView];
}

-(void)paginateScrollView:(UIScrollView *)scrollView {
    
    NSUInteger nextPage = currentPage;
    
    if (self.contentOffset.x != departurePoint.x && paginationInProgress == NO) {
        
        if (self.contentOffset.x> departurePoint.x) {
            nextPage++;
        } else {
            nextPage--;
        }
        
        if ([pageArray count] > 0 && nextPage < [pageArray count]) {
            [self scrollToPage:nextPage];
        }
    } else if (paginationInProgress == YES) {
        [self setContentOffset:destinationPoint animated:YES];
    }
    
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    self.scrollingFromTouch = YES;
    return  [super hitTest:point withEvent:event];
}
-(void)scrollToPageWithNotif:(NSNotification *)notif {
    self.scrollingFromTouch = NO;
    NSNumber *page = notif.userInfo[KeyForPageNumberInUserInfo];
    [self scrollToPage:[page integerValue]];
}

-(void)scrollToPage:(NSInteger)page {
    
    if (currentPage != page) {
        
        NSDictionary *params = @{@"from_page": [NSNumber numberWithInteger:currentPage], @"to_page" : [NSNumber numberWithInteger:page]};
        [Flurry logEvent:@"page_movement" withParameters:params];
        CGPoint pagePoint = [self frameAtIndex:page].origin;
        departurePoint = [self frameAtIndex:currentPage].origin;
        destinationPoint = pagePoint;
        paginationInProgress = YES;
        self.scrollEnabled = NO;
        currentPage = page;
        [self setContentOffset:pagePoint animated:YES];
        departurePoint = pagePoint;
    }
}

@end
