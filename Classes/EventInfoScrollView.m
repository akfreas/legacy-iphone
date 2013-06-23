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
#import "FigureRowScrollPage.h"

@interface EventInfoScrollView () <UIScrollViewDelegate>

@end

@implementation EventInfoScrollView {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfFigureRows;
    NSFetchedResultsController *fetchedResultsController;
    
    UIPageControl *pageControl;
    NSMutableArray *pageArray;
    CGPoint lastPoint;
    AtYourAgeConnection *connection;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
//        self.contentSize = CGSizeMake(320, Utility_AppSettings.frameForKeyWindow.size.height);
        self.delegate = self;
        lastPoint = CGPointZero;
        accessor = [ObjectArchiveAccessor sharedInstance];
        pageArray = [NSMutableArray array];
        arrayOfFigureRows = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithRed:13/255 green:20/355 blue:20/255 alpha:1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEventInfoPageAndScroll:) name:KeyForInfoOverlayButtonTapped object:nil];
    }
    return self;
}

-(void)addFigurePage {
    FigureRowScrollPage *figurePage = [[FigureRowScrollPage alloc] initWithFrame:self.bounds];
    [self addSubview:figurePage];
    [figurePage reload];
}

-(void)addEventInfoPageAndScroll:(NSNotification *)notif {
    
    
    CGRect infoFrame = CGRectMake(320 + SpaceBetweenFigureRowPages, self.contentOffset.y, 320, 400);
    NSDictionary *userInfo = notif.userInfo;
    Event *theEvent = userInfo[@"event"];
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetRelatedEventsForEvent:[theEvent.eventId stringValue] requester:nil];
    connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    [self addPageControl];
    MainFigureInfoPage *infoPage = [[MainFigureInfoPage alloc] initWithFrame:infoFrame];
    infoPage.event = theEvent;
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, NSDictionary *eventDict, NSError *error) {
        [pageArray addObject:infoPage];
        [infoPage expandWithRelatedEvents:eventDict completion:^(BOOL expanded) {
            infoPage.frame = CGRectSetSizeOnFrame(infoFrame, self.bounds.size);
            [self scrollToPage:1];
            
            AtYourAgeWebView *webView = [[AtYourAgeWebView alloc] initWithFrame:CGRectOffset(infoFrame, 320 + SpaceBetweenFigureRowPages, 0)];
            webView.frame = CGRectSetHeightForRect(self.bounds.size.height, webView.frame);
            webView.event = theEvent;
            [pageArray addObject:webView];

            [self addSubview:webView];
            self.contentSize = CGSizeAddWidthToSize(self.contentSize, infoPage.frame.size.width + webView.frame.size.width);
//            self.contentSize = CGRectSetWidthForRect(self.contentSize.width, self.bounds).size;


        }];
    }];
    
    
    [self addSubview:infoPage];
    
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
    [self addFigurePage];
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self paginateScrollView:scrollView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x == 0 && [pageArray count] > 0) {
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:pageArray];
        for (int i=0; i < [pageArray count]; i++) {
            
            UIView <FigureRowPageProtocol> *page = [pageArray objectAtIndex:i];
            
            [page removeFromSuperview];
            [newArray removeObject:page];
        }
        self.contentSize = CGSizeMake(self.bounds.size.width, ([arrayOfFigureRows count] + 1) * (FigureRowPageInitialHeight + EventInfoScrollViewPadding));
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
            if ([page isKindOfClass:[AtYourAgeWebView class]]) {
                [(AtYourAgeWebView *)page loadRequest];
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
