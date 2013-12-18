#import "SwipeMessage.h"
#import "AMBlurView.h"
#import "FigureRowHorizontalScrollView.h"
#import "EventPersonRelation.h"
#import "LegacyWebView.h"
#import "EventInfoTableView.h"
#import "FigureRowTablePage.h"


@interface SwipeMessage () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation SwipeMessage {
    
    IBOutlet UIView *hostingBlurView;
    IBOutlet UIView *swipeMessageDisplay;
    IBOutlet UIView *figureRowCellPlaceholder;
    IBOutlet UIView *timelineAnnotationHostingView;
    IBOutlet UIView *webviewAnnotationHostingView;
    IBOutlet UIView *mainTouchInterceptionView;
    
    
    
    IBOutlet UIView *facebookAnnotationHostingView;
    IBOutlet UIImageView *facebookChevron;
    IBOutlet UIImageView *connectWithFacebookAnnotation;
    
    IBOutlet UIButton *doneButton;
    
    IBOutlet UISwipeGestureRecognizer *swipeGestureRecognizer;
    
    IBOutletCollection(UIView) NSArray *uiComponents;
    IBOutletCollection(UIView) NSMutableArray *fourthStepUIComponents;
    UIView *superView;
    
    NSMutableArray *selectorStack;
    
    FigureRowHorizontalScrollView *exampleRow;
    UIView *exampleRowBackground;
    CGFloat topToolbar;
}

CGFloat InfoPageWidth = 280;

- (id)initWithSuperView:(UIView *)view
{
    self = [super init];
    
    if (self) {
        
        
        topToolbar = 0;
        if(SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            topToolbar = 20;
        }
        superView = view;
        
        [[NSBundle mainBundle] loadNibNamed:@"SwipeMessage_OS7" owner:self options:nil];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            [hostingBlurView setValue:[UIColor colorWithWhite:1 alpha:.1] forKey:@"blurTintColor"];
        } else {
            hostingBlurView.tintColor = [UIColor colorWithWhite:1 alpha:0.6f];
            hostingBlurView.backgroundColor = [UIColor clearColor];
//            [[NSBundle mainBundle] loadNibNamed:@"SwipeMessage" owner:self options:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrolledToPageNotification:) name:KeyForHasScrolledToPageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollingFromPageNotification:) name:KeyForScrollingFromPageNotification object:nil];
        [self setupSelectorStack];
    }
    return self;
}

-(void)setupSelectorStack {
    selectorStack = [NSMutableArray arrayWithArray:@[
                                                     
//                                                     @[NSStringFromSelector(@selector(configureViewForFourthStep))],
//                                                     @[NSStringFromSelector(@selector(finalCleanup))],

                     @[NSStringFromSelector(@selector(configureViewForFirstStep))],
                      @[NSStringFromSelector(@selector(cleanUpFromFirstStep)), NSStringFromSelector(@selector(configureViewForSecondStep))],
                      @[NSStringFromSelector(@selector(cleanUpFromSecondStep)), NSStringFromSelector(@selector(configureViewForThirdStep))],
                      @[NSStringFromSelector(@selector(cleanUpFromThirdStep)), NSStringFromSelector(@selector(configureViewForFourthStep))],
                     @[NSStringFromSelector(@selector(finalCleanup))]
                     ]];
}

-(void)handleScrollingFromPageNotification:(NSNotification *)notif {
    
    Class pageClass = notif.userInfo[KeyForPageTypeInUserInfo];
    if ([FigureRowTablePage class] == pageClass) {
        [self advanceInState];
    }
}

-(void)handleScrolledToPageNotification:(NSNotification *)notif {
    
    
}


#pragma mark UIGestureRecognizer Methods
- (IBAction)swipeAction:(id)sender {
    [self advanceInState];
}

-(void)advanceInState {
    
    NSArray *topSelectors = [selectorStack objectAtIndex:0];
    
    for (NSString *selectorString in topSelectors) {
        [self performSelector:NSSelectorFromString(selectorString)];
    }
    
    [selectorStack removeObjectAtIndex:0];
}

#pragma mark Cleanup Methods

-(void)cleanUpFromFirstStep {
    
    [exampleRow removeFromSuperview];
    [swipeMessageDisplay removeFromSuperview];
    [exampleRowBackground removeFromSuperview];
    [UIView animateWithDuration:0.2 animations:^{
        hostingBlurView.alpha = 0;
    } completion:^(BOOL finished) {
        [hostingBlurView removeFromSuperview];
    }];
}

-(void)cleanUpFromSecondStep {
    [self removeTimelineAnnotationView:^{
        
    }];
}

-(void)cleanUpFromThirdStep {
    superView.frame = CGRectSetOriginOnRect(superView.frame, 0, topToolbar);
    [self removeWebviewAnnotationView];
}

-(void)finalCleanup {
    
    [UIView animateWithDuration:1.0f animations:^{
        
        for (UIView *view in uiComponents) {
            view.transform = CGAffineTransformMakeScale(5, 5);
            view.alpha = 0;
        }

    } completion:^(BOOL finished) {
        for (UIView *view in uiComponents) {
            [view removeFromSuperview];
        }
    }];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForHasBeenShownSwipeMessage];
    [swipeGestureRecognizer removeTarget:self action:NULL];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark Configuration Methods


-(void)configureViewWithInterceptionView {
    [superView addSubview:mainTouchInterceptionView];
}

-(void)configureViewForFirstStep {

//    hostingBlurView.autoresizingMask = superView.autoresizingMask;
    hostingBlurView.frame = [UIApplication sharedApplication].keyWindow.frame;
//    hostingBlurView.alpha = 0;
    [superView addSubview:hostingBlurView];
    [UIView animateWithDuration:0.2f animations:^{
        hostingBlurView.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            [self pulseView:swipeMessageDisplay];
        }
    }];
}

-(void)configureViewForSecondStep {
    [self configureViewWithInterceptionView];
    
    [self addTimelineAnnotationView];
}

-(void)configureViewForThirdStep {
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForScrollToPageNotification object:nil userInfo:@{KeyForPageNumberInUserInfo: [NSNumber numberWithInteger:3]}];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addWebviewAnnotationView];
}

-(void)configureViewForFourthStep {
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForScrollToPageNotification object:nil userInfo:@{KeyForPageNumberInUserInfo: [NSNumber numberWithInteger:1]}];
    [mainTouchInterceptionView removeFromSuperview];
    [fourthStepUIComponents sortUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        if (view1.tag > view2.tag) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    doneButton.titleLabel.font = [UIFont fontWithName:@"Cinzel-Regular" size:30.0];
    
    [superView addSubview:facebookAnnotationHostingView];
    facebookAnnotationHostingView.autoresizesSubviews = NO;
    UIView *facebookCircleButton = [superView viewWithTag:8];
    facebookAnnotationHostingView.frame = CGRectMake(0, facebookCircleButton.frame.size.height + facebookCircleButton.frame.origin.y, superView.frame.size.width, superView.frame.size.height - facebookCircleButton.frame.origin.y);
    facebookChevron.frame = CGRectSetOriginOnRect(facebookChevron.frame, facebookCircleButton.frame.origin.x + facebookChevron.bounds.size.width / 4, 0);
    [self pulseView:facebookChevron withTransformFactor:1.2f];
    [self fadeInFourthStepUIViews];
}

-(void)fadeInFourthStepUIViews {
    
    if ([fourthStepUIComponents count] > 0) {
        UIView *view = [fourthStepUIComponents objectAtIndex:0];
        [UIView animateWithDuration:0.5f animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            [fourthStepUIComponents removeObjectAtIndex:0];
            [self fadeInFourthStepUIViews];
        }];
    }
}

-(void)addTimelineAnnotationView {
    timelineAnnotationHostingView.frame = CGRectSetOriginOnRect(timelineAnnotationHostingView.frame, 0, -timelineAnnotationHostingView.frame.size.height);
    timelineAnnotationHostingView.alpha = 0;
    [superView insertSubview:timelineAnnotationHostingView belowSubview:mainTouchInterceptionView];
    [UIView animateWithDuration:0.5f animations:^{
        timelineAnnotationHostingView.frame = CGRectSetOriginOnRect(timelineAnnotationHostingView.frame, 0, 0);
        timelineAnnotationHostingView.alpha = 1;
    } completion:^(BOOL finished) {
        [self pulseView:timelineAnnotationHostingView];
    }];
}

-(IBAction)doneButtonPressed:(id)sender {
    [self advanceInState];
}

-(void)removeTimelineAnnotationView:(void(^)())completion {
    [UIView animateWithDuration:0.1f animations:^{
        timelineAnnotationHostingView.alpha = 0;
    } completion:^(BOOL finished) {
        [timelineAnnotationHostingView removeGestureRecognizer:[[timelineAnnotationHostingView gestureRecognizers] lastObject]];
        [timelineAnnotationHostingView removeFromSuperview];
        if (finished) {
            completion();
        }
    }];
}

-(void)addWebviewAnnotationView {
    
    
    webviewAnnotationHostingView.alpha = 0;
    superView.frame = CGRectSetOriginOnRect(superView.frame, superView.frame.origin.x, webviewAnnotationHostingView.frame.size.height - 44 + topToolbar);
    [superView insertSubview:webviewAnnotationHostingView belowSubview:mainTouchInterceptionView];
    webviewAnnotationHostingView.frame = CGRectSetOriginOnRect(webviewAnnotationHostingView.frame, superView.frame.size.width, -webviewAnnotationHostingView.frame.size.height / 2 + topToolbar);
    [UIView animateWithDuration:0.5f animations:^{
        webviewAnnotationHostingView.frame = CGRectSetOriginOnRect(webviewAnnotationHostingView.frame, 0, -webviewAnnotationHostingView.frame.size.height + 44); //TODO: this is a hack.
        webviewAnnotationHostingView.alpha = 1;
    } completion:^(BOOL finished) {
        
        [self pulseView:webviewAnnotationHostingView];
    }];
}

-(void)removeWebviewAnnotationView {
    
    webviewAnnotationHostingView.alpha = 0;
    [webviewAnnotationHostingView removeFromSuperview];

}

-(void)setEventRelation:(EventPersonRelation *)rowData cellOrigin:(CGPoint)rowLocation {
    
    
    exampleRow = [[FigureRowHorizontalScrollView alloc] initWithOrigin:CGPointMake(0, 200)];
    exampleRow.allowsSelection = NO;
    exampleRow.event = rowData.event;
    exampleRow.person = rowData.person;
    [figureRowCellPlaceholder removeFromSuperview];
    [hostingBlurView addSubview:exampleRow];
    exampleRowBackground = [[UIView alloc] initWithFrame:exampleRow.frame];
    exampleRowBackground.backgroundColor = [UIColor whiteColor];
    [hostingBlurView insertSubview:exampleRowBackground belowSubview:exampleRow];
}

-(void)pulseView:(UIView *)view {
    [self pulseView:view withTransformFactor:1.05];
}

-(void)pulseView:(UIView *)view withTransformFactor:(CGFloat)trans {
    
    if ([view superview] != nil) {
        [UIView animateWithDuration:.5 animations:^{
            view.transform = CGAffineTransformMakeScale(trans, trans);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.5 animations:^{
                view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
                view.transform = CGAffineTransformIdentity;
                [self pulseView:view withTransformFactor:trans];
            }];
        }];
    }
}

-(void)show {
    [self advanceInState];
}

@end
