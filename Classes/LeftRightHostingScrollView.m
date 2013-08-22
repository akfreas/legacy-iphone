#import "LeftRightHostingScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "EventDescriptionView.h"
#import "FigureRow.h"
#import "Event.h"
#import "LegacyWebView.h"
#import "FigureRowHostingScrollPage.h"
#import "EventInfoTableView.h"

@interface LeftRightHostingScrollView () <UIScrollViewDelegate>

@end

@implementation LeftRightHostingScrollView {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfFigureRows;
    NSFetchedResultsController *fetchedResultsController;
    
    UIPageControl *pageControl;
    NSMutableArray *pageArray;
    FigureRowHostingScrollPage *figurePage;
    CGPoint lastPoint;
    LegacyAppConnection *connection;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        lastPoint = CGPointZero;
        accessor = [ObjectArchiveAccessor sharedInstance];
        pageArray = [NSMutableArray array];
        arrayOfFigureRows = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithRed:13/255 green:20/355 blue:20/255 alpha:1];
        self.contentSize = self.bounds.size;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEventInfoPageAndScroll:) name:KeyForInfoOverlayButtonTapped object:nil];
        [self addFigurePage];
        [self addPageControl];

    }
    return self;
}

-(void)addFigurePage {
    figurePage = [[FigureRowHostingScrollPage alloc] initWithFrame:self.bounds];
    [self addSubview:figurePage];
}

-(void)addEventInfoPageAndScroll:(NSNotification *)notif {
    
    
    CGRect infoFrame = CGRectMake(320 + SpaceBetweenFigureRowPages, self.contentOffset.y, 320, 400);
    NSDictionary *userInfo = notif.userInfo;
    Event *theEvent = userInfo[@"event"];
    Person *thePerson = userInfo[@"person"];
    
    EventInfoTableView *infoPage = [[EventInfoTableView alloc] initWithEvent:theEvent];
    
    infoPage.frame = infoFrame;
    NSArray *relatedEvents = [accessor eventsForFigure:theEvent.figure];
    [pageArray addObject:infoPage];
    [infoPage reloadData];
    [self addSubview:infoPage];
    [self scrollToPage:1];
    
    if ([notif.object isKindOfClass:[FigureRow class]]) {
        FigureRow *theRow = (FigureRow *)notif.object;
        [theRow reset];
    }
    
    LegacyWebView *webView = [[LegacyWebView alloc] initWithFrame:CGRectOffset(infoFrame, 320 + SpaceBetweenFigureRowPages, 0)];
    webView.frame = CGRectSetHeightForRect(self.bounds.size.height, webView.frame);
    webView.event = theEvent;
    [webView loadRequest];
    [pageArray addObject:webView];
    [self insertSubview:webView belowSubview:pageControl];

    self.contentSize = CGSizeAddWidthToSize(self.contentSize, infoPage.frame.size.width + webView.frame.size.width * SpaceBetweenFigureRowPages * [pageArray count]);

}




-(void)addPageControl {
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(PageControlXPosition, PageControlYPosition, PageControlWidthPerPage * 3, PageControlHeight)];
    pageControl.layer.cornerRadius = PageControlCornerRadius;
    pageControl.alpha = 0;
    pageControl.currentPage = 1;
    pageControl.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.2];
    pageControl.numberOfPages = 3;
    pageControl.userInteractionEnabled = NO;
    [self addSubview:pageControl];
    
}



-(CGRect)frameAtIndex:(NSInteger)index {
    CGFloat padding = 5;
    CGFloat width = Utility_AppSettings.frameForKeyWindow.size.height;

    return CGRectMake(0, (FigureRowPageInitialHeight + FigureRowScrollViewPadding)  * index, width, FigureRowPageInitialHeight);
}

-(void)removeInfoViews {
    for (UIView *infoView in arrayOfFigureRows) {
        [infoView removeFromSuperview];
    }
    [arrayOfFigureRows removeAllObjects];
}

-(void)reload {
    if (figurePage == nil) {
        [self addFigurePage];
    }
    [figurePage reload];
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self paginateScrollView:scrollView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x > self.bounds.size.width) {
        pageControl.frame = CGRectMake(scrollView.contentOffset.x + 20, pageControl.frame.origin.y, pageControl.frame.size.width, pageControl.frame.size.height);
        if (pageControl.alpha != 1) {
            [UIView animateWithDuration:0.2 animations:^{
                pageControl.alpha = 1;
            }];
        }
    }
    if (scrollView.contentOffset.x == 0 && [pageArray count] > 0) {
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:pageArray];
        for (int i=0; i < [pageArray count]; i++) {
            
            UIView <FigureRowPageProtocol> *page = [pageArray objectAtIndex:i];
            
            [page removeFromSuperview];
            [newArray removeObject:page];
            page = nil;
        }
        self.contentSize = CGSizeMake(self.bounds.size.width, ([arrayOfFigureRows count] + 1) * (FigureRowPageInitialHeight + FigureRowScrollViewPadding));
        pageArray = newArray;
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
    
    if (self.contentOffset.x != lastPoint.x) {
        if (self.contentOffset.x > lastPoint.x) {
            pageControl.currentPage++;
        } else {
            pageControl.currentPage--;
        }
        
        if (pageControl.currentPage > 0 && [pageArray count] > 0 && pageControl.currentPage <= [pageArray count]) {
            UIView <FigureRowPageProtocol> *page = pageArray[pageControl.currentPage - 1];
            lastPoint = CGPointMake(page.frame.origin.x, 0);
            if ([page isKindOfClass:[LegacyWebView class]]) {
                [(LegacyWebView *)page loadRequest];
            }
            [self scrollToPage:pageControl.currentPage];
        } else {
            [self scrollToPage:0];
        }
    }
}

-(void)scrollToPage:(NSInteger)page {
    
    CGFloat xPoint = 0;

    if (page > 0) {
        UIView <FigureRowPageProtocol> *pageView = pageArray[page - 1];
        xPoint = pageView.frame.origin.x;
    } else {
        xPoint = 0;
    }
    pageControl.currentPage = page;
    CGPoint pagePoint = CGPointMake(xPoint, self.contentOffset.y);
    lastPoint = pagePoint;
    [self setContentOffset:pagePoint animated:YES];
}

@end
