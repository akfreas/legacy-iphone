#import "PersonRow.h"
#import "MainFigureInfoPage.h"
#import "DescriptionPage.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "ObjectArchiveAccessor.h"
#import "Figure.h"
#import "Event.h"


@implementation PersonRow {
    
    MainFigureInfoPage *infoPage;
    DescriptionPage *descriptionPage;
    AtYourAgeConnection *connection;
    Event *event;
    Figure *figure;
    
    UILabel *figureNameLabel;
    UIPageControl *pageControl;
    UIScrollView *scroller;
    UIButton *moreCloseButton;
    UIActivityIndicatorView *indicator;
    CGPoint lastPoint;
}


CGFloat pageWidth = 320;

- (id)initWithOrigin:(CGPoint)origin
{
    CGRect frame = CGRectMake(origin.x, origin.y, 320, PageRowInitialHeight);
    self = [super initWithFrame:frame];
    if (self) {

        [self initInfoPage];
        [self registerForNotifications];
        [self addScrollViewWithFrame:frame];
        [self addPageControl];
        [self addMoreLessButton];
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

-(void)initInfoPage {
    infoPage = [[MainFigureInfoPage alloc] initWithFrame:CGRectMake(0, 0, pageWidth, PageRowInitialHeight)];
}

-(void)registerForNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentsChangedSize:) name:KeyForPersonRowHeightChanged object:infoPage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventLoadingComplete:) name:KeyForEventLoadingComplete object:infoPage.widgetContainer];
    
}


-(void)addScrollViewWithFrame:(CGRect)frame {
    scroller = [[UIScrollView alloc] initWithFrame:CGRectMakeFrameWithSizeFromFrame(frame)];
    scroller.scrollEnabled = NO;
    scroller.contentSize = CGSizeMake(pageWidth * 2 + SpaceBetweenPersonRowPages, infoPage.frame.size.height);
    scroller.delegate = self;
    [self addSubview:scroller];

}

-(void)addPageControl {
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(PageControlXPosition, PageControlYPosition, PageControlWidth, PageControlHeight)];
    pageControl.layer.cornerRadius = PageControlCornerRadius;
    pageControl.alpha = 0;
    pageControl.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.2];
    pageControl.numberOfPages = 2;
    pageControl.userInteractionEnabled = NO;
    [self addSubview:pageControl];

}


-(void)setPerson:(Person *)person {
    _person = person;
    infoPage.person = person;
    
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetStoryForPerson:person];
    
    connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, Event *result, NSError *error) {
        NSLog(@"Event Fetch Result: %@", result);
        event = result;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addFigureNameLabel];
            
        });
        
        if (event != nil) {
            [self fetchFigureAndAddDescriptionPage];
            infoPage.event = event;
            
        }
    }];
    [scroller addSubview:infoPage];
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
            [self addDescriptionPage];
        });
    }];
    
}

-(void)addFigureNameLabel {
    
    CGSize labelSize = CGSizeMake(200, 50);
    figureNameLabel = [[UILabel alloc] initWithFrame:CGRectMakeFrameForCenter(self, labelSize, 0)];
    figureNameLabel.backgroundColor = [UIColor clearColor];
    figureNameLabel.text = event.figureName;
    [self addSubview:figureNameLabel];
}

-(void)addDescriptionPage {
    
    descriptionPage = [[DescriptionPage alloc] initWithFigure:figure];
    
    [descriptionPage setNeedsLayout];
    
    [scroller addSubview:descriptionPage];
    descriptionPage.frame = CGRectMake(pageWidth + SpaceBetweenPersonRowPages, 0, 20, infoPage.frame.size.height);
    
}

-(void)contentsChangedSize:(NSNotification *)notif {
    CGRect f = self.frame;
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
        newHeight = PageRowInitialHeight;
        newDelta = PageRowInitialHeight - self.frame.size.height;
        [moreCloseButton setTitle:@"More" forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame =  CGRectMake(f.origin.x, f.origin.y, f.size.width, newHeight);
        scroller.frame = CGRectMakeFrameWithSizeFromFrame(self.frame);
        descriptionPage.frame = CGRectMake(infoPage.frame.size.width + SpaceBetweenPersonRowPages, 0, 320, newHeight);
        moreCloseButton.frame = CGRectMakeFrameWithOriginInBottomOfFrame(self.frame, CGRectGetWidth(moreCloseButton.frame), CGRectGetHeight(moreCloseButton.frame));
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
    
    lastPoint = CGPointMake(pageControl.currentPage * pageWidth + pageControl.currentPage * SpaceBetweenPersonRowPages, 0);
//    if (lastPoint.x < scrollView.contentSize.width) {
        [scrollView setContentOffset:lastPoint animated:YES];
//    }
}

@end