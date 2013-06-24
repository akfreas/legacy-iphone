#import "FigureRow.h"
#import "MainFigureInfoPage.h"
#import "LeftActionTabPage.h"
#import "DescriptionPage.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "ObjectArchiveAccessor.h"
#import "Figure.h"
#import "Event.h"
#import "FigureRowPageProtocol.h"
#import "AtYourAgeWebView.h"
#import "FigureRowActionOverlay.h"


@implementation FigureRow {
    
    MainFigureInfoPage *infoPage;
    AtYourAgeWebView *webView;
    LeftActionTabPage *tabPage;
    FigureRowActionOverlay *actionOverlay;
    
    AtYourAgeConnection *connection;
    
    UILabel *figureNameLabel;
    UIPageControl *pageControl;
    NSMutableArray *pageArray;
    UIView *nameContainerView;
    CGPoint lastPoint;
}


CGFloat pageWidth = 320;

- (id)initWithOrigin:(CGPoint)origin
{
    CGRect frame = CGRectMake(origin.x, origin.y, FigureRowPageWidth, FigureRowPageInitialHeight);
    self = [super initWithFrame:frame];
    if (self) {

//        [self addMoreLessButton];
        [self setupPages];
        [self registerForNotifications];
        [self addTapGestureRecognizer];
    }
    return self;
}


-(void)addTapGestureRecognizer {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addActionOverlay)];
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOnRow)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
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

}

-(void)removeActionOverlay:(NSNotification *)notif {
    
    if (notif.object != self) {
        [actionOverlay hide];
    }
}

-(void)registerForNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentsChangedSize:) name:KeyForFigureRowHeightChanged object:infoPage];
    
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