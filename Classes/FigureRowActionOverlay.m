#import "FigureRowActionOverlay.h"
#import "CircleImageView.h"
#import "Event.h"
#import "Flurry.h"

@implementation FigureRowActionOverlay {
    
    NSMutableArray *circleImageViews;
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
        self.infoButtonAction = NULL;
        self.deleteButtonAction = NULL;
        self.facebookButtonAction = NULL;
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

-(CircleImageView *)deleteCircle {
    CircleImageView *deleteCircle = [[CircleImageView alloc] initWithImage:[UIImage imageNamed:@"298-circlex@2x"] radius:OverlayViewButtonRadius];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteAction)];
    [deleteCircle addGestureRecognizer:tapGesture];
    
    return deleteCircle;
}

-(void)setAlphaOnCircleViews:(CGFloat)alpha {
    for (CircleImageView *circleView in circleImageViews) {
        if ([circleView isKindOfClass:[CircleImageView class]]) {
            circleView.alpha = alpha;
        }
    }
}

-(void)prepareCircles {
    
    circleImageViews = [NSMutableArray array];
    
    if (self.deleteButtonAction != NULL) {
        [circleImageViews addObject:[self deleteCircle]];
    }
    [circleImageViews addObjectsFromArray:@[[NSNumber numberWithFloat:130], [self infoCircle]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        [circleImageViews addObject:[self fbCircle]];
    }
    

    CGPoint startPoint = CGPointMake(0, self.frame.size.height / 2 - OverlayViewButtonRadius);
    
    CGFloat originXOffset = 0;
    CGFloat padding = 10;
    
    for (int i=0; i < [circleImageViews count]; i++) {
        
        id imageItem = [circleImageViews objectAtIndex:i];
        if ([imageItem isKindOfClass:[CircleImageView class]]) {
            CircleImageView *circleView = (CircleImageView*)imageItem;
            CGFloat xPointForCircle = startPoint.x + originXOffset + padding;
            
            CGPoint layerOrigin = CGPointMake(xPointForCircle, startPoint.y);
            circleView.frame = CGRectSetOriginOnRect(circleView.frame, layerOrigin.x, layerOrigin.y);
            originXOffset += circleView.frame.size.width + padding;
        } else if ([imageItem isKindOfClass:[NSNumber class]]) {
            NSNumber *paddingItem = (NSNumber *)imageItem;
            originXOffset += [paddingItem floatValue];
        }

    }
    
    CGPoint centerOfFrame = CGPointGetCenterFromRect(self.frame);
    CGFloat centeredXOffset = centerOfFrame.x - originXOffset / 2;
    
    for (CircleImageView *circleView in circleImageViews) {
        if ([circleView isKindOfClass:[CircleImageView class]]) {
            circleView.frame = CGRectOffset(circleView.frame, centeredXOffset, 0);
            [self addSubview:circleView];
        }
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

-(void)deleteAction {
    if (self.deleteButtonAction != NULL) {
        self.deleteButtonAction();
    }
}

@end
