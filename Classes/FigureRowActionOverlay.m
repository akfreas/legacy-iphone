#import "FigureRowActionOverlay.h"
#import "CircleImageView.h"
#import "Event.h"

@implementation FigureRowActionOverlay {
    
    NSArray *circleImageViews;
    Event *event;
}

-(id)initWithEvent:(Event *)theEvent {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        event = theEvent;
        self.animationDuration = 0.05;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.alpha = 0;
        [self addTapGestureRecognizer];
    }
    return self;
}

-(void)addTapGestureRecognizer {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:gesture];
}

-(void)hide {
    [UIView animateWithDuration:_animationDuration animations:^{
        self.alpha = 0;
        [self setAlphaOnCircleViews:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)showInView:(UIView *)superView {
    
    self.frame = CGRectMakeFrameWithSizeFromFrame(superView.frame);
    [self prepareCircles];
    [superView addSubview:self];
    [UIView animateWithDuration:_animationDuration animations:^{
        self.alpha = 1;
        [self setAlphaOnCircleViews:1];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    }];
}

-(CircleImageView *)fbCircle {
    CircleImageView *fbCircle = [[CircleImageView alloc] initWithImage:[UIImage imageNamed:@"FB-f-Logo__blue_100.png"] radius:OverlayViewButtonRadius];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fbAction)];
    
    [fbCircle addGestureRecognizer:tapGesture];
    return fbCircle;
}

-(CircleImageView *)infoCircle {
    CircleImageView *infoCircle = [[CircleImageView alloc] initWithImage:[UIImage imageNamed:@"informationcircle.png"] radius:OverlayViewButtonRadius];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoAction)];
    
    [infoCircle addGestureRecognizer:tapGesture];
    
    return infoCircle;
}

-(void)setAlphaOnCircleViews:(CGFloat)alpha {
    for (CircleImageView *circleView in circleImageViews) {
        circleView.alpha = alpha;
    }
}

-(void)prepareCircles {
    
    
    
    circleImageViews = [NSArray arrayWithObjects:[self fbCircle], [self infoCircle], nil];

    CGPoint startPoint = CGPointMake(0, self.frame.size.height / 2 - OverlayViewButtonRadius);
    
    CGFloat originXOffset = 0;
    CGFloat padding = 5;
    
    for (int i=0; i < [circleImageViews count]; i++) {
        
        CircleImageView *circleView = [circleImageViews objectAtIndex:i];
        CGFloat xPointForCircle = startPoint.x + originXOffset + padding;
        
        CGPoint layerOrigin = CGPointMake(xPointForCircle, startPoint.y);
        circleView.frame = CGRectSetOriginOnRect(circleView.frame, layerOrigin.x, layerOrigin.y);
        originXOffset += circleView.frame.size.width + padding;

    }
    
    CGPoint centerOfFrame = CGPointGetCenterFromRect(self.frame);
    CGFloat centeredXOffset = centerOfFrame.x - originXOffset / 2;
    
    for (CircleImageView *circleView in circleImageViews) {
        circleView.frame = CGRectOffset(circleView.frame, centeredXOffset, 0);
        [self addSubview:circleView];
    }
    [self setAlphaOnCircleViews:0];
    [self setNeedsLayout];
}

#pragma mark Button Actions

-(void)fbAction {
    if (self.facebookButtonAction != NULL) {
        self.facebookButtonAction();
    }
}

-(void)infoAction {
    if (self.infoButtonAction != NULL) {
        self.infoButtonAction();
    }
}

@end
