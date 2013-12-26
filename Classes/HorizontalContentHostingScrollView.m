#import "HorizontalContentHostingScrollView.h"
#import "Person.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "FigureRowHorizontalScrollView.h"
#import "Event.h"
#import "EventPersonRelation.h"
#import "LegacyWebView.h"
#import "FigureRowTablePage.h"
#import "EventInfoTableView.h"
#import "LegacyInfoPage.h"
#import "WebViewControls.h"

@interface HorizontalContentHostingScrollView () <UIScrollViewDelegate>
@end

typedef enum ScrollViewDirection {
    ScrollViewDirectionRight,
    ScrollViewDirectionLeft,
} ScrollViewDirection;

@implementation HorizontalContentHostingScrollView {
    NSMutableArray *arrayOfFigureRows;
    NSFetchedResultsController *fetchedResultsController;
    
    NSInteger currentPage;
    NSMutableArray *pageArray;
    FigureRowTablePage *figurePage;
    CGPoint departurePoint;
    CGPoint destinationPoint;
    CGPoint lastScrollPoint;
    BOOL paginationInProgress;
    LegacyAppConnection *connection;
    WebViewControls *controls;
    ScrollViewDirection direction;
}

#define InfoPageNumber 999
#define LandingPageNumber 0
#define TimelinePageNumber LandingPageNumber + 1
#define WebViewPageNumber TimelinePageNumber + 1
#define LastPageNumber WebViewPageNumber + 1

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
        arrayOfFigureRows = [[NSMutableArray alloc] init];
        controls = [[WebViewControls alloc] initWithOrigin:CGPointMake(self.contentOffset.x, 0)];
        self.contentSize = CGSizeMake(0, self.bounds.size.height);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEventInfoPageAndScroll:) name:KeyForInfoOverlayButtonTapped object:nil];
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToInfoPage) name:@"ScrollToInfo" object:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToPageWithNotif:) name:KeyForScrollToPageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToLandingPage) name:KeyForLoggedIntoFacebookNotification object:nil];
        [self addFigurePage];
        [self scrollToPage:LandingPageNumber];
    }
    return self;
}

-(void)scrollToInfoPage {
    [self scrollToPage:InfoPageNumber];
}

-(void)scrollToLandingPage {
    [self scrollToPage:LandingPageNumber];
}

-(void)addFigurePage {
    
    figurePage = [[FigureRowTablePage alloc] initWithFrame:[self frameAtIndex:LandingPageNumber]];
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
    
    
    NSDictionary *userInfo = notif.userInfo;
    EventPersonRelation *relation = userInfo[@"relation"];
    
    EventInfoTableView *infoPage = [[EventInfoTableView alloc] initWithRelation:relation];
    infoPage.frame = [self frameAtIndex:TimelinePageNumber];
    [infoPage reloadData];
    [self addPage:infoPage];
    [self scrollToPage:TimelinePageNumber];
    
    if ([notif.object isKindOfClass:[FigureRowHorizontalScrollView class]]) {
        FigureRowHorizontalScrollView *theRow = (FigureRowHorizontalScrollView *)notif.object;
        [theRow delayedReset];
    }
    
}



-(CGRect)frameAtIndex:(NSInteger)index {
    
    CGRect windowFrame = [[[[UIApplication sharedApplication] windows] lastObject] frame];
    return CGRectMake((self.bounds.size.width + SpaceBetweenFigureRowPages) * index , 0, self.bounds.size.width, windowFrame.size.height);
}

-(void)removeInfoViews {
    for (UIView *infoView in arrayOfFigureRows) {
        [infoView removeFromSuperview];
    }
    [arrayOfFigureRows removeAllObjects];
}

-(void)checkIfScrollCompletedAndNotifyPage {
    
    if (CGPointEqualToPoint(self.contentOffset, destinationPoint)) {
        paginationInProgress = NO;
        self.scrollEnabled = YES;
        UIView <PageProtocol> *page = [pageArray objectAtIndex:currentPage];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForHasScrolledToPageNotification object:nil userInfo:@{KeyForPageTypeInUserInfo: [page class]}];
        if ([page isKindOfClass:[EventInfoTableView class]] && currentPage == [pageArray count] - 1) {
            
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
        
        if (self.contentOffset.x > departurePoint.x) {
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


-(void)scrollToPageWithNotif:(NSNotification *)notif {
    
    NSNumber *page = notif.userInfo[KeyForPageNumberInUserInfo];
    
    [self scrollToPage:[page integerValue]];
}

-(void)scrollToPage:(NSInteger)page {
    
    if (currentPage != page) {
        
        
        NSDictionary *params = @{@"from_page": [NSNumber numberWithInteger:currentPage], @"to_page" : [NSNumber numberWithInteger:page]};
        [Flurry logEvent:@"page_movement" withParameters:params];
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForScrollingFromPageNotification object:nil userInfo:@{KeyForPageTypeInUserInfo: [[pageArray objectAtIndex:currentPage] class]}];
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
