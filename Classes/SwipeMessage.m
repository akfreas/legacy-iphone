#import "SwipeMessage.h"
#import "AMBlurView.h"

@interface SwipeMessage () <UIScrollViewDelegate>

@end

@implementation SwipeMessage {
    
    IBOutlet UIView *hostingView;
    IBOutlet UIView *swipeMessageDisplay;
    IBOutlet UIView *scrollViewPlaceholder;
    IBOutlet UIScrollView *infoScrollView;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIView *firstView;
    IBOutlet UIView *secondView;
    
    IBOutletCollection(UIView) NSArray *pageViews;
    UIView *superView;
}

CGFloat InfoPageWidth = 280;

- (id)initWithSuperView:(UIView *)view
{
    self = [super init];
    
    if (self) {
        superView = view;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            [[NSBundle mainBundle] loadNibNamed:@"SwipeMessage_OS7" owner:self options:nil];
            [hostingView setValue:[UIColor colorWithWhite:1 alpha:.1] forKey:@"blurTintColor"];
        }
        hostingView.autoresizingMask = view.autoresizingMask;
        hostingView.alpha = 0;
        [view addSubview:hostingView];
        [self setupScrollView];
    }
    return self;
}

-(void)setupScrollView {
    
    for (UIView *page in pageViews) {
        page.frame = CGRectSetOriginOnRect(page.frame, infoScrollView.contentSize.width, 0);
        [infoScrollView addSubview:page];
        infoScrollView.contentSize = CGSizeAddWidthToSize(infoScrollView.contentSize, page.frame.size.width);
    }
}

-(void)addTapGesture {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [hostingView addGestureRecognizer:tapGesture];
}

-(void)startTimerForTapGestureRecognizer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(addTapGesture) userInfo:Nil repeats:NO];
    [timer fire];
}

-(void)show {
    
    [UIView animateWithDuration:0.2f animations:^{
        hostingView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            swipeMessageDisplay.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                swipeMessageDisplay.transform = CGAffineTransformIdentity;
                [self startTimerForTapGestureRecognizer];
            }];
        }];
    }];
}

-(void)hide {
    
    [UIView animateWithDuration:0.5f animations:^{
        hostingView.alpha = 0;
    } completion:^(BOOL finished) {
        [hostingView removeFromSuperview];
    }];
}

#pragma mark UIScrollView Delegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    pageControl.currentPage = scrollView.contentOffset.x / InfoPageWidth;
    
}

@end
