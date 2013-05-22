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
}

CGFloat pageSpace = 0;
CGFloat pageWidth = 320;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        
        infoPage = [[MainFigureInfoPage alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentsChangedSize:) name:KeyForPersonRowHeightChanged object:infoPage];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventLoadingComplete:) name:KeyForEventLoadingComplete object:infoPage.widgetContainer];
        
        scroller = [[UIScrollView alloc] initWithFrame:CGRectMakeFrameWithSizeFromFrame(frame)];
        scroller.scrollEnabled = NO;
        scroller.contentSize = CGSizeMake(pageWidth * 2 + pageSpace, infoPage.frame.size.height);
        scroller.delegate = self;
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(260, 20, 40, 20)];
//        pageControl.pageIndicatorTintColor = [UIColor orangeColor];
//        pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        pageControl.layer.cornerRadius = 10.0;
        pageControl.alpha = 0;
        pageControl.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.2];
        pageControl.numberOfPages = 2;
        [self addSubview:scroller];
        [self addSubview:pageControl];
    
    }
    return self;
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
    
    UITapGestureRecognizer *touchUp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [infoPage addGestureRecognizer:touchUp];
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
    descriptionPage.frame = CGRectMake(pageWidth + pageSpace, 0, 20, infoPage.frame.size.height);
    
}

-(void)contentsChangedSize:(NSNotification *)notif {
    CGRect f = self.frame;
    CGFloat delta = [[notif.userInfo objectForKey:@"delta"] floatValue];
    
    [UIView animateWithDuration:0 animations:^{
        self.frame =  CGRectMake(f.origin.x, f.origin.y, f.size.width, f.size.height + delta);
        scroller.frame = CGRectMakeFrameWithSizeFromFrame(self.frame);
        descriptionPage.frame = CGRectMake(infoPage.frame.size.width + pageSpace, 0, 320, infoPage.frame.size.height + delta);

        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForPersonRowContentChanged object:self userInfo:notif.userInfo];
    }];
    
}

-(void)tapped {
    [infoPage toggleExpandWithCompletion:^(BOOL expanded) {
        scroller.scrollEnabled = expanded;
        [UIView animateWithDuration:.2 animations:^{
            pageControl.alpha = (int)expanded;
        }];
    }];
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self paginateScrollView:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self paginateScrollView:scrollView];
    }
}

-(void)paginateScrollView:(UIScrollView *)scrollView {
    
    CGFloat pagePercent = 0.5;

    int page = (((int)scrollView.contentOffset.x) / ((int)pageWidth * pagePercent ));
    pageControl.currentPage = page;
    CGPoint pagePoint = CGPointMake(page * pageWidth + page *pageSpace, 0);
    if (pagePoint.x < scrollView.contentSize.width) {
        [scrollView setContentOffset:pagePoint animated:YES];
    }
}

@end
