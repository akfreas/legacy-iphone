#import "FigureRow.h"
#import "MainFigureInfoPage.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "Figure.h"
#import "Event.h"
#import "Person.h"
#import "FigureRowPageProtocol.h"
#import "LegacyWebView.h"
#import "FigureRowActionOverlay.h"
#import <FacebookSDK/FBNativeDialogs.h>
@interface FigureRow () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation FigureRow {
    
    MainFigureInfoPage *infoPage;
    LegacyWebView *webView;
    FigureRowActionOverlay *actionOverlay;
    
    LegacyAppConnection *connection;
    
    UILabel *figureNameLabel;
    UIPageControl *pageControl;
    NSMutableArray *pageArray;
    UIView *nameContainerView;
    
    UISwipeGestureRecognizer *swipeGesture;
    UITapGestureRecognizer *tapGesture;
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

    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addActionOverlay)];
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(beginSwiping:)];
    swipeGesture.delegate = self;
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeGesture];
    [self addGestureRecognizer:tapGesture];
}


-(void)addActionOverlay {
    
    NSMutableDictionary *flurryDict = [NSMutableDictionary new];
    
    flurryDict[@"event"] = _event;
    
    if (_person != nil) {
        flurryDict[@"person_id"] = _person.facebookId;
    }
    
    if (actionOverlay == nil) {
        actionOverlay = [[FigureRowActionOverlay alloc] initWithEvent:self.event];
    }
    NSNotification *infoButtonNotification = [NSNotification notificationWithName:KeyForInfoOverlayButtonTapped object:self userInfo:@{@"event": _event}];
    actionOverlay.infoButtonAction = ^{
        [Flurry logEvent:@"tapped_info_button" withParameters:flurryDict];
        [[NSNotificationCenter defaultCenter] postNotification:infoButtonNotification];
    };
    if (_person != nil && [_person.isPrimary isEqualToNumber:[NSNumber numberWithBool:YES]] == NO) {
        NSNotification *deleteNotif = [NSNotification notificationWithName:KeyForRemovePersonButtonTappedNotification object:self userInfo:@{@"person" : _person}];
        actionOverlay.deleteButtonAction = ^{
            [Flurry logEvent:@"tapped_delete_button" withParameters:flurryDict];
            [[NSNotificationCenter defaultCenter] postNotification:deleteNotif];
        };
    }
    NSNotification *facebookNotification = [NSNotification notificationWithName:KeyForFacebookButtonTapped object:self userInfo:@{@"event" : _event}];
    actionOverlay.facebookButtonAction = ^{
        [Flurry logEvent:@"tapped_fb_share_buttton" withParameters:flurryDict];
        [[NSNotificationCenter defaultCenter] postNotification:facebookNotification];
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForOverlayViewShown object:self];
    
    [actionOverlay showInView:self];

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
    [self performSelector:@selector(resetContentOffset) withObject:self afterDelay:.2];
}

-(void)resetContentOffset {
    self.contentOffset = CGPointZero;
    self.scrollEnabled = YES;
    isSwiping = NO;
}

-(void)removeActionOverlay:(NSNotification *)notif {
    
    if (notif.object != self) {
        [self removeActionOverlay];
    }
}

-(void)removeActionOverlay {
    [actionOverlay hide];
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
    infoPage.person = person;
}

-(BOOL)selected {
    if ([actionOverlay superview] == self) {
        return YES;
    } else {
        return NO;
    }
}

-(void)setSelected:(BOOL)selected {
    if (selected) {
        [self addActionOverlay];
    } else {
        [self removeActionOverlay];
    }
}

-(void)setAllowsSelection:(BOOL)allowsSelection {
    if (allowsSelection) {
        [self addTapGestureRecognizer];
    } else {
        [tapGesture removeTarget:self action:NULL];
        [swipeGesture removeTarget:self action:NULL];
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
        CGFloat widthDelta = CGRectGetWidth(page.frame) + SpaceBetweenFigureRowPages;
        currentXOffset += widthDelta;
    }
}

-(MainFigureInfoPage *)figureInfoPage {
    infoPage = [[MainFigureInfoPage alloc] initWithFrame:CGRectMake(0, 0, FigureRowPageWidth, FigureRowPageInitialHeight)];
    return infoPage;
}


@end