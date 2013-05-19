#import "RightIndicatorLines.h"

@implementation RightIndicatorLines {
    
    UIBezierPath *path;
}

-(id)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    
    if (self = [self initWithFrame:CGRectMake(startPoint.x, startPoint.y, 200, 400)]) {
        _lineStartPoint = startPoint;
        _lineEndPoint = endPoint;
//        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setLineEndPoint:(CGPoint)lineEndPoint {
    _lineEndPoint = lineEndPoint;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (CGPointEqualToPoint(_lineEndPoint, CGPointZero) == false) {
        [self drawLines];
    }
}

-(void)drawLines {
    
    path = [UIBezierPath bezierPath];
    
    path.lineWidth = 2.0;
    path.lineJoinStyle = kCGLineJoinRound;
    [[UIColor redColor] setStroke];
    
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(_lineEndPoint.x, 20)];
    [path addLineToPoint:_lineEndPoint];

    [path stroke];
}

@end
