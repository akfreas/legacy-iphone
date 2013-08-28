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
#import "LegacyInfoPage.h"

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

#define InfoPageNumber 0
#define LandingPageNumber InfoPageNumber + 1
#define TimelinePageNumber LandingPageNumber + 1
#define WebViewPageNumber TimelinePageNumber + 1
#define LastPageNumber WebViewPageNumber



-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        lastPoint = CGPointZero;
        accessor = [ObjectArchiveAccessor sharedInstance];
        arrayOfFigureRows = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithRed:13/255 green:20/355 blue:20/255 alpha:1];
        self.contentSize = CGSizeMake(0, self.bounds.size.height);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEventInfoPageAndScroll:) name:KeyForInfoOverlayButtonTapped object:nil];
        [self addPageControl];
        [self addLegacyInfoPage];
        [self addFigurePage];
        [self scrollToPage:LandingPageNumber];
    }
    return self;
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
        newContentSize = CGSizeAddWidthToSize(newContentSize, pageSize.height + SpaceBetweenFigureRowPages);
    }
    NSLog(@"New content size: %@", CGSizeCreateDictionaryRepresentation(newContentSize));
    self.contentSize = newContentSize;
    
}

-(void)addEventInfoPageAndScroll:(NSNotification *)notif {
    
    
    NSDictionary *userInfo = notif.userInfo;
    Event *theEvent = userInfo[@"event"];
    
    EventInfoTableView *infoPage = [[EventInfoTableView alloc] initWithEvent:theEvent];
    
    infoPage.frame = [self frameAtIndex:TimelinePageNumber];
    [infoPage reloadData];
    [self addPage:infoPage];
    [self scrollToPage:TimelinePageNumber];
    
    if ([notif.object isKindOfClass:[FigureRow class]]) {
        FigureRow *theRow = (FigureRow *)notif.object;
        [theRow reset];
    }
    
    LegacyWebView *webView = [[LegacyWebView alloc] initWithFrame:[self frameAtIndex:WebViewPageNumber]];
    webView.frame = CGRectSetHeightForRect(self.bounds.size.height, webView.frame);
    webView.event = theEvent;
    [webView loadRequest];
    [self addPage:webView];
}




-(void)addPageControl {
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(PageControlXPosition, PageControlYPosition, PageControlWidthPerPage * 3, PageControlHeight)];
    pageControl.layer.cornerRadius = PageControlCornerRadius;
    pageControl.alpha = 0;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.2];
    pageControl.numberOfPages = LastPageNumber;
    pageControl.userInteractionEnabled = NO;
    [self addSubview:pageControl];
    
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

    if (self.contentOffset.x != lastPoint.x) {
        if (self.contentOffset.x > lastPoint.x) {
            pageControl.currentPage++;
        } else {
            pageControl.currentPage--;
        }
        
        if (pageControl.currentPage > 0 && [pageArray count] > 0 && pageControl.currentPage < [pageArray count]) {
            UIView <FigureRowPageProtocol> *page = pageArray[pageControl.currentPage];
            lastPoint = CGPointMake(page.frame.origin.x, 0);
            if ([page isKindOfClass:[LegacyWebView class]]) {
                [(LegacyWebView *)page loadRequest];
            } 
            [self scrollToPage:pageControl.currentPage];
        } else {
            [self scrollToPage:LandingPageNumber];
        }
    }
}

-(void)scrollToPage:(NSInteger)page {
    
    CGFloat xPoint = 0;

    UIView <FigureRowPageProtocol> *pageView = pageArray[page];
    xPoint = pageView.frame.origin.x;
    pageControl.currentPage = page;
    CGPoint pagePoint = CGPointMake(xPoint, self.contentOffset.y);
    [self setContentOffset:pagePoint animated:YES];
    lastPoint = pagePoint;
}

@end
