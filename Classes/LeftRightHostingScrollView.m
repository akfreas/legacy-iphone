    #import "LeftRightHostingScrollView.h"
#import "Person.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "FigureRow.h"
#import "Event.h"
#import "LegacyWebView.h"
#import "FigureRowHostingScrollPage.h"
#import "EventInfoTableView.h"
#import "LegacyInfoPage.h"
#import "WebViewControls.h"

@interface LeftRightHostingScrollView () <UIScrollViewDelegate>
@end

typedef enum ScrollViewDirection {
    ScrollViewDirectionRight,
    ScrollViewDirectionLeft,
} ScrollViewDirection;

@implementation LeftRightHostingScrollView {
    NSMutableArray *arrayOfFigureRows;
    NSFetchedResultsController *fetchedResultsController;
    
    UIPageControl *pageControl;
    NSMutableArray *pageArray;
    FigureRowHostingScrollPage *figurePage;
    CGPoint departurePoint;
    CGPoint destinationPoint;
    CGPoint lastScrollPoint;
    BOOL paginationInProgress;
    LegacyAppConnection *connection;
    WebViewControls *controls;
    ScrollViewDirection direction;
}

#define InfoPageNumber 0
#define LandingPageNumber InfoPageNumber + 1
#define TimelinePageNumber LandingPageNumber + 1
#define WebViewPageNumber TimelinePageNumber + 1
#define LastPageNumber WebViewPageNumber + 1



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
        self.backgroundColor = [UIColor colorWithRed:13/255 green:20/355 blue:20/255 alpha:1];
        self.contentSize = CGSizeMake(0, self.bounds.size.height);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEventInfoPageAndScroll:) name:KeyForInfoOverlayButtonTapped object:nil];
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToInfoPage) name:@"ScrollToInfo" object:nil];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToLandingPage) name:KeyForLoggedIntoFacebookNotification object:nil];
        [self addPageControl];
        [self addLegacyInfoPage];
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
    
    figurePage = [[FigureRowHostingScrollPage alloc] initWithFrame:[self frameAtIndex:LandingPageNumber]];
    [self addPage:figurePage];
}

-(void)addLegacyInfoPage {
    
    LegacyInfoPage *infoPage = [[LegacyInfoPage alloc] initWithFrame:[self frameAtIndex:InfoPageNumber]];
    [self addPage:infoPage];
}

-(void)addPage:(UIView <FigureRowPageProtocol> *)page {
    if (pageArray == nil) {
        pageArray = [NSMutableArray array];
    }
    [pageArray addObject:page];
    page.frame = [self frameAtIndex:[pageArray count] - 1];
    [self insertSubview:page belowSubview:pageControl];
    self.contentSize = CGSizeAddWidthToSize(self.contentSize, page.frame.size.width + SpaceBetweenFigureRowPages);
    
}


-(void)removePage:(UIView <FigureRowPageProtocol> *)page {
    
    [page removeFromSuperview];
    [pageArray removeObject:page];
    
    CGSize newContentSize = CGSizeMake(0, self.bounds.size.height);
    
    for (UIView <FigureRowPageProtocol> *thePage in pageArray) {
        CGSize pageSize = thePage.frame.size;
        newContentSize = CGSizeAddWidthToSize(newContentSize, pageSize.width + SpaceBetweenFigureRowPages);
    }
    self.contentSize = newContentSize;
    
}

-(void)addEventInfoPageAndScroll:(NSNotification *)notif {
    
    
    NSDictionary *userInfo = notif.userInfo;
    Event *theEvent = userInfo[@"event"];
    
    EventInfoTableView *infoPage = [[EventInfoTableView alloc] initWithEvent:theEvent];
    infoPage.person = userInfo[@"person"];
    infoPage.frame = [self frameAtIndex:TimelinePageNumber];
    [infoPage reloadData];
    [self addPage:infoPage];
    [self scrollToPage:TimelinePageNumber];
    
    if ([notif.object isKindOfClass:[FigureRow class]]) {
        FigureRow *theRow = (FigureRow *)notif.object;
        [theRow reset];
    }
    
}




-(void)addPageControl {
    
    CGFloat pageControlWidth = 20 * 4;
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - pageControlWidth / 2, PageControlYPosition, pageControlWidth, PageControlHeight)];
    pageControl.layer.cornerRadius = PageControlCornerRadius;
    pageControl.alpha = 0;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.2];
    pageControl.numberOfPages = LastPageNumber;
    pageControl.userInteractionEnabled = NO;
//    [self addSubview:pageControl];
    
}



-(CGRect)frameAtIndex:(NSInteger)index {
    return CGRectMake((self.bounds.size.width + SpaceBetweenFigureRowPages) * index , 0, self.bounds.size.width, self.bounds.size.height);
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
        UIView <FigureRowPageProtocol> *page = [pageArray objectAtIndex:pageControl.currentPage];
        if ([page isKindOfClass:[EventInfoTableView class]] && pageControl.currentPage == [pageArray count] - 1) {
            
            LegacyWebView *webView = [[LegacyWebView alloc] initWithFrame:[self frameAtIndex:WebViewPageNumber]];
            webView.frame = CGRectSetHeightForRect(self.bounds.size.height, webView.frame);
            webView.event = page.event;
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
        UIView <FigureRowPageProtocol> *page = pageArray[pageIndex];
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
    if (scrollView.contentOffset.x > self.bounds.size.width * 2) {
        pageControl.frame = CGRectMake (scrollView.contentOffset.x + (self.bounds.size.width / 2 - (20 * 4) / 2), pageControl.frame.origin.y, pageControl.frame.size.width, pageControl.frame.size.height);
        if (pageControl.alpha != 1) {
            [UIView animateWithDuration:0.2 animations:^{
                pageControl.alpha = 1;
            }];
        }
    }
    if (scrollView.contentOffset.x == [self frameAtIndex:LandingPageNumber].origin.x && [pageArray count] > 0) {
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:pageArray];
        for (int i=LandingPageNumber + 1; i < [newArray count]; i++) {
            
            UIView <FigureRowPageProtocol> *page = [newArray objectAtIndex:i];
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
    
    NSUInteger nextPage = pageControl.currentPage;
    
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


-(void)scrollToPage:(NSInteger)page {
    
    if (pageControl.currentPage != page) {
        
        
        NSDictionary *params = @{@"from_page": [NSNumber numberWithInteger:pageControl.currentPage], @"to_page" : [NSNumber numberWithInteger:page]};
        [Flurry logEvent:@"page_movement" withParameters:params];
        
        CGPoint pagePoint = [self frameAtIndex:page].origin;
        departurePoint = [self frameAtIndex:pageControl.currentPage].origin;
        destinationPoint = pagePoint;
        paginationInProgress = YES;
        self.scrollEnabled = NO;
        pageControl.currentPage = page;
        [self setContentOffset:pagePoint animated:YES];
        departurePoint = pagePoint;
    }
}

@end
