#import "FigureRow.h"
#import "MainFigureInfoPage.h"
#import "LeftActionTabPage.h"
#import "DescriptionPage.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "Figure.h"
#import "Event.h"
#import "FigureRowPageProtocol.h"
#import "LegacyWebView.h"
#import "FigureRowActionOverlay.h"

@interface FigureRow () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation FigureRow {
    
    MainFigureInfoPage *infoPage;
    LegacyWebView *webView;
    LeftActionTabPage *tabPage;
    FigureRowActionOverlay *actionOverlay;
    
    LegacyAppConnection *connection;
    
    UILabel *figureNameLabel;
    UIPageControl *pageControl;
    NSMutableArray *pageArray;
    UIView *nameContainerView;
    
    UISwipeGestureRecognizer *swipeGesture;
    CGPoint lastPoint;
    BOOL isSwiping;
}


CGFloat pageWidth = 320;

- (id)initWithOrigin:(CGPoint)origin
{
    CGRect frame = CGRectMake(origin.x, origin.y, FigureRowPageWidth, FigureRowPageInitialHeight);
    self = [super initWithFrame:frame];
    if (self) {

//        [self addMoreLessButton];
        self.contentSize = CGSizeAddWidthToSize(self.bounds.size, 100);
        self.bounces = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.scrollEnabled = YES;
        [self setupPages];
        [self registerForNotifications];
        [self addTapGestureRecognizer];
    }
    return self;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [actionOverlay hide];
    if (scrollView.tracking == NO && scrollView.contentOffset.x > 10 && isSwiping == NO) {
        
        isSwiping = YES;
    } else if (isSwiping == YES) {
        scrollView.scrollEnabled = NO;
        scrollView.bounces = NO;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.x > 0) {
        [self swipeOnRow];
    }
}

#pragma mark Gesture Recognizer Methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (gestureRecognizer == swipeGesture || otherGestureRecognizer == swipeGesture) {
        return YES;
    } else {
        return NO;
    }
}

-(void)beginSwiping:(id)test {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ScrollToInfo" object:nil];
}

-(void)addTapGestureRecognizer {

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addActionOverlay)];
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(beginSwiping:)];
    swipeGesture.delegate = self;
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeGesture];
    [self addGestureRecognizer:gesture];
}


-(void)addActionOverlay {
    if (actionOverlay == nil) {
        actionOverlay = [[FigureRowActionOverlay alloc] initWithEvent:self.event];
    }
    [actionOverlay showInView:self];
    NSNotification *infoButtonNotification = [NSNotification notificationWithName:KeyForInfoOverlayButtonTapped object:self userInfo:@{@"event": _event}];
    actionOverlay.infoButtonAction = ^{
        [[NSNotificationCenter defaultCenter] postNotification:infoButtonNotification];
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForOverlayViewShown object:self];
}

-(void)swipeOnRow {
    
    NSDictionary *userInfo;
    if (_person == nil) {
        userInfo = @{@"event": _event};
    } else {
        userInfo = @{@"event": _event, @"person" : _person};
    }
    NSNotification *infoButtonNotification = [NSNotification notificationWithName:KeyForInfoOverlayButtonTapped object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:infoButtonNotification];
    self.bounces = NO;
    isSwiping = NO;
}

-(void)reset {
    [self performSelector:@selector(resetContentOffset) withObject:self afterDelay:1];
}

-(void)resetContentOffset {
    self.contentOffset = CGPointZero;
    self.scrollEnabled = YES;
    isSwiping = NO;
}

-(void)removeActionOverlay:(NSNotification *)notif {
    
    if (notif.object != self) {
        [actionOverlay hide];
    }
}

-(void)registerForNotifications {
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeActionOverlay:) name:KeyForOverlayViewShown object:nil];
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Accessors



-(void)setEvent:(Event *)event {
    
    _event = event;
    if (event != nil) {
        infoPage.event = event;
    }
}

-(void)setPerson:(Person *)person {
    _person = person;
    if (person != nil) {
        infoPage.person = person;
    }
}

#pragma mark Page Management

-(void)setupPages {
    pageArray = [NSMutableArray arrayWithObjects:[self figureInfoPage], nil];
    
    [self setPageFrames];
    
    for (UIView <FigureRowPageProtocol> *page in pageArray) {
        [self addSubview:page];
    }
}

-(void)setPageFrames {
    
    CGFloat currentXOffset = 0;
    
    for (int i=0; i < [pageArray count]; i++) {
        UIView <FigureRowPageProtocol> *page = pageArray[i];
        page.frame = CGRectSetOriginOnRect(page.frame, currentXOffset, 0);
        CGFloat widthDelta = CGRectGetWidth(page.frame) + page.rightPageMargin;
        currentXOffset += widthDelta;
    }
}

-(MainFigureInfoPage *)figureInfoPage {
    infoPage = [[MainFigureInfoPage alloc] initWithFrame:CGRectMake(0, 0, FigureRowPageWidth, FigureRowPageInitialHeight)];
    return infoPage;
}


@end