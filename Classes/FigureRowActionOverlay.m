#import "FigureRowActionOverlay.h"
#import "CircleImageLayer.h"
#import "Event.h"

@implementation FigureRowActionOverlay {
    
    NSArray *circleImageLayers;
    Event *event;
}

-(id)initWithEvent:(Event *)theEvent {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        event = theEvent;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    }
    return self;
}

-(void)showInView:(UIView *)superView {
    
    self.frame = CGRectMakeFrameWithSizeFromFrame(superView.frame);
    [self prepareCircles];
    [superView addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    }];
}

-(void)prepareCircles {
    
    
    CGFloat radius = 20;
    CircleImageLayer *fbCircle = [[CircleImageLayer alloc] initWithImage:[UIImage imageNamed:@"FB-f-Logo__blue_100.png"] radius:radius];
    CircleImageLayer *infoCircle = [[CircleImageLayer alloc] initWithImage:[UIImage imageNamed:@"informationcircle.png"] radius:radius];

    circleImageLayers = [NSArray arrayWithObjects:fbCircle, infoCircle, nil];

    CGPoint startPoint = CGPointMake(0, self.frame.size.height / 2 - radius);
    
    CGFloat originXOffset = 0;
    CGFloat padding = 5;
    
    for (int i=0; i < [circleImageLayers count]; i++) {
        
        CircleImageLayer *layer = [circleImageLayers objectAtIndex:i];
        CGFloat xPointForCircle = startPoint.x + originXOffset + padding;
        
        CGPoint layerOrigin = CGPointMake(xPointForCircle, startPoint.y);
        layer.frame = CGRectSetOriginOnRect(layer.frame, layerOrigin.x, layerOrigin.y);
        originXOffset += layer.frame.size.width + padding;

    }
    
    CGPoint centerOfFrame = CGPointGetCenterFromRect(self.frame);
    CGFloat centeredXOffset = centerOfFrame.x - originXOffset / 2;
    
    for (CircleImageLayer *layer in circleImageLayers) {
        layer.frame = CGRectOffset(layer.frame, centeredXOffset, 0);
        [self.layer addSublayer:layer];
    }
    [self setNeedsLayout];
}

@end
