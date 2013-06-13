#import "PersonRow.h"
#import "MainFigureInfoPage.h"
#import "LeftActionTabPage.h"
#import "DescriptionPage.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "ObjectArchiveAccessor.h"
#import "Figure.h"
#import "Event.h"
#import "PersonRowPageProtocol.h"
#import "AtYourAgeWebView.h"


@implementation PersonRow {
    
    MainFigureInfoPage *infoPage;
    AtYourAgeWebView *webView;
    LeftActionTabPage *tabPage;
    
    AtYourAgeConnection *connection;
    Event *event;
    Figure *figure;
    
    UILabel *figureNameLabel;
    UIPageControl *pageControl;
    UIScrollView *scroller;
    UIButton *moreCloseButton;
    UIActivityIndicatorView *indicator;
    NSMutableArray *pageArray;
    UIView *nameContainerView;
    CGPoint lastPoint;
}


CGFloat pageWidth = 320;

- (id)initWithOrigin:(CGPoint)origin
{
    CGRect frame = CGRectMake(origin.x, origin.y, PersonRowPageWidth, PersonRowPageInitialHeight);
    self = [super initWithFrame:frame];
    if (self) {

        [self addScrollViewWithFrame:frame];
        [self addMoreLessButton];
        [self setupPages];
        [self registerForNotifications];
        scroller.backgroundColor = [UIColor blackColor];
    }
    return self;
}


-(void)addMoreLessButton {
    
    moreCloseButton = [[UIButton alloc] initWithFrame:CGRectMakeFrameWithOriginInBottomOfFrame(self.frame, MoreCloseButtonWidth, MoreCloseButtonHeight)];
    moreCloseButton.backgroundColor = [UIColor grayColor];
    moreCloseButton.layer.cornerRadius = MoreCloseButtonCornerRadius;
    [moreCloseButton addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    moreCloseButton.userInteractionEnabled = NO;
    [moreCloseButton setTitle:@"More" forState:UIControlStateNormal];
    [self addSubview:moreCloseButton];
    
}


-(void)registerForNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentsChangedSize:) name:KeyForPersonRowHeightChanged object:infoPage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventLoadingComplete:) name:KeyForEventLoadingComplete object:infoPage.widgetContainer];
    
}


-(void)addScrollViewWithFrame:(CGRect)frame {
    scroller = [[UIScrollView alloc] initWithFrame:CGRectMakeFrameWithSizeFromFrame(frame)];
    scroller.scrollEnabled = NO;
    scroller.contentSize = CGSizeZero;
    scroller.delegate = self;
    scroller.showsHorizontalScrollIndicator = NO;
    [self addSubview:scroller];

}

-(void)addPageControl {
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(PageControlXPosition, PageControlYPosition, PageControlWidthPerPage * [pageArray count], PageControlHeight)];
    pageControl.layer.cornerRadius = PageControlCornerRadius;
    pageControl.alpha = 0;
    pageControl.currentPage = 1;
    pageControl.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.2];
    pageControl.numberOfPages = [pageArray count];
    pageControl.userInteractionEnabled = NO;
    [nameContainerView addSubview:pageControl];

}

-(void)addFigureNameLabel {
    
    CGSize labelSize = CGSizeMake(200, nameContainerView.frame.size.height);
    figureNameLabel = [[UILabel alloc] initWithFrame:CGRectMakeFrameForCenter(nameContainerView, labelSize, 0)];
    figureNameLabel.backgroundColor = [UIColor clearColor];
    figureNameLabel.textAlignment = NSTextAlignmentCenter;
    figureNameLabel.text = event.figureName;
    [nameContainerView addSubview:figureNameLabel];
}

-(void)addNameContainerView {
    nameContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, PersonRowNameContainerViewHeight)];
    nameContainerView.backgroundColor = [UIColor clearColor];
    [self addSubview:nameContainerView];
    
    [self addPageControl];
    [self addFigureNameLabel];
}



-(void)setPerson:(Person *)person {
    _person = person;

    tabPage.person = _person;
    infoPage.person = person;
    
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetStoryForPerson:person];
    
    connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, Event *result, NSError *error) {
        NSLog(@"Event Fetch Result: %@", result);
        event = result;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addNameContainerView];
            
        });
        
        if (event != nil) {
            [self fetchFigureAndAddDescriptionPage];
            infoPage.event = event;
            tabPage.event = event;
            webView.event = event;
        }
    }];
}

-(void)eventLoadingComplete:(NSNotification *)notif {
    moreCloseButton.userInteractionEnabled = YES;
}

-(void)fetchFigureAndAddDescriptionPage {
    
    
    Person *requester = [[ObjectArchiveAccessor sharedInstance] primaryPerson];
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetFigureWithId:event.figureId requester:requester];
    
    connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, Figure *result, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            figure = result;
        });
    }];
    
}



#pragma mark Page Management

-(void)setupPages {
    pageArray = [NSMutableArray arrayWithObjects:[self leftActionTabPage], [self figureInfoPage], [self webView], nil];
    
    [self setPageFrames];
    
    for (UIView <PersonRowPageProtocol> *page in pageArray) {
        [scroller addSubview:page];
    }
}

-(void)setPageFrames {
    
    CGFloat currentXOffset = 0;
    for (int i=0; i < [pageArray count]; i++) {
        UIView <PersonRowPageProtocol> *page = pageArray[i];
        page.frame = CGRectSetOriginOnRect(page.frame, currentXOffset, 0);
        CGFloat widthDelta = CGRectGetWidth(page.frame) + page.rightPageMargin;
        scroller.contentSize = CGSizeAddWidthToSize(scroller.contentSize, widthDelta);
        if (i == 0) {
            scroller.contentOffset = CGPointMake(CGRectGetWidth(page.frame), 0);
        }
        currentXOffset += widthDelta;
    }
}

-(LeftActionTabPage *)leftActionTabPage {
    
    CGPoint tabPageOrigin = CGPointMake(0, 0);
    tabPage = [[LeftActionTabPage alloc] initWithOrigin:tabPageOrigin  height:self.frame.size.height];
    return tabPage;
}

-(MainFigureInfoPage *)figureInfoPage {
    infoPage = [[MainFigureInfoPage alloc] initWithFrame:CGRectMake(0, 0, PersonRowPageWidth, PersonRowPageInitialHeight)];
    return infoPage;
}

-(AtYourAgeWebView *)webView {
    
    CGRect webViewFrame = CGRectMake(0, 0, pageWidth, self.frame.size.height);
    CGRect offsetFrame = CGRectOffset(webViewFrame, infoPage.frame.origin.x  + infoPage.frame.size.width, 0);
    webView = [[AtYourAgeWebView alloc] initWithFrame:offsetFrame];
    return webView;
}

-(void)contentsChangedSize:(NSNotification *)notif {

    CGFloat delta = [[notif.userInfo objectForKey:@"delta"] floatValue];
    CGFloat newDelta;
    CGFloat newHeight;
    if (delta > 0) {
        if (delta + self.frame.size.height > [UIApplication sharedApplication].keyWindow.frame.size.height) {
            newHeight = [UIApplication sharedApplication].keyWindow.frame.size.height - 44 - 20;
            newDelta = newHeight - self.frame.size.height + MoreCloseButtonHeight;
        } else {
            newHeight = self.frame.size.height + delta + MoreCloseButtonHeight;// + CGRectGetHeight(moreLessButton.frame));
            newDelta = delta + MoreCloseButtonHeight;
        }
        [moreCloseButton setTitle:@"Close" forState:UIControlStateNormal];
    } else {
        newHeight = PersonRowPageInitialHeight;
        newDelta = PersonRowPageInitialHeight - self.frame.size.height;
        [moreCloseButton setTitle:@"More" forState:UIControlStateNormal];
    }
    
    
    [self setPageFrames];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame =  CGRectSetHeightForRect(newHeight, self.frame);
        
        for (UIView <PersonRowPageProtocol> *page in pageArray) {
            page.frame = CGRectSetHeightForRect(newHeight, page.frame);
        }
        scroller.frame = CGRectMakeFrameWithSizeFromFrame(self.frame);
        
        moreCloseButton.frame = CGRectMakeFrameWithOriginInBottomOfFrame(self.frame, CGRectGetWidth(moreCloseButton.frame), CGRectGetHeight(moreCloseButton.frame));
        tabPage.height = newHeight;
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForPersonRowContentChanged object:self userInfo:@{@"delta": [NSNumber numberWithFloat:newDelta]}];
    }];
    
}

-(void)tapped {
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetRelatedEventsForEvent:event.eventId requester:_person];
    connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    if (infoPage.expanded == NO) {
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.frame = CGRectMake(0, 0, MoreCloseButtonHeight, MoreCloseButtonHeight);
        [indicator startAnimating];
        [moreCloseButton addSubview:indicator];
        
        [connection getWithCompletionBlock:^(AtYourAgeRequest *request, NSDictionary *eventDict, NSError *error) {
            [indicator stopAnimating];
            [indicator removeFromSuperview];
            [infoPage expandWithRelatedEvents:eventDict completion:^(BOOL expanded) {
                scroller.scrollEnabled = YES;
                [UIView animateWithDuration:.2 animations:^{
                    pageControl.alpha = 1;
                    pageControl.currentPage = [pageArray indexOfObject:infoPage];
                }];
            }];
        }];
    } else {
        
        [infoPage collapseWithCompletion:^(BOOL expanded) {
            scroller.scrollEnabled = expanded;
            [UIView animateWithDuration:.2 animations:^{
                pageControl.alpha = (int)expanded;
            }];
        }];
    }
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self paginateScrollView:scrollView];
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
    
    if (scrollView.contentOffset.x > lastPoint.x) {
        pageControl.currentPage++;
    } else {
        pageControl.currentPage--;
    }
    
    UIView <PersonRowPageProtocol> *page = pageArray[pageControl.currentPage];
    lastPoint = CGPointMake(page.frame.origin.x, 0);
        [scrollView setContentOffset:lastPoint animated:YES];
    if ([page isKindOfClass:[AtYourAgeWebView class]]) {
        [(AtYourAgeWebView *)page loadRequest];
    }
}

@end