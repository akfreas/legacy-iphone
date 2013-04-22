//
//  Staple.m
//  AtYourAge
//
//  Created by Alexander Freas on 4/15/13.
//
//

#import "Staple.h"

@implementation Staple {
    
    CGPoint beginPoint;
    CGPoint endPoint;
    
    CGPoint centerPoint;
    CGFloat lineLength;
}

-(id)initWithCenterPoint:(CGPoint)theCenterPoint angle:(CGFloat)theAngle length:(CGFloat)theLength {

    
    CGRect frame = CGRectMake(theCenterPoint.x - theLength/2, theCenterPoint.y - theLength/2, theLength * 2, theLength * 2);
    
    
    self = [super initWithFrame:frame];
    self.center = theCenterPoint;
    
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];

        _angle = theAngle;
        lineLength = theLength;
        centerPoint = theCenterPoint;
//        self.transform = CGAffineTransformMakeRotation(angle / M_PI);

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

-(void)setAngle:(CGFloat)angle {
    _angle = angle;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    
//    CGContextRef c = UIGraphicsGetCurrentContext();
//    CGFloat black[4] = {0.0f, 0.0f, 0.0f, 1.0f};
//
//    CGContextSetStrokeColor(c, black);
    
    
    CGFloat opposite = lineLength/2;
    CGFloat adjacent = opposite / tanf(_angle);
    CGPoint theBeginPoint =  CGPointMake(self.frame.size.width / 2 - adjacent, self.frame.size.height / 2 - opposite);
    CGPoint theEndPoint = CGPointMake(self.frame.size.width / 2 + adjacent, self.frame.size.height / 2 + opposite);
    
    CGFloat width = theEndPoint.x - theBeginPoint.x;
    CGFloat height = theEndPoint.y - theBeginPoint.y;
    CGContextRef c = UIGraphicsGetCurrentContext();

    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 2.0;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineCapStyle = kCGLineCapRound;

//    [path moveToPoint:CGPointMake(self.frame.size.width * 0.05, self.frame.size.height / 2)];
    
//    [path addLineToPoint:CGPointMake(self.frame.size.width - self.frame.size.width * 0.05, self.frame.size.height / 2)];
    [path moveToPoint:theBeginPoint];
//    [path moveToPoint:theEndPoint];
    [path addLineToPoint:theEndPoint];
    [path stroke];
//    CGContextRotateCTM(c, angle/M_PI);
//    CGContextSaveGState(c);
//    CGFloat black[4] = {0.0f, 0.0f, 0.0f, 0.0f};
//    CGContextSetStrokeColor(c, black);
//    CGContextBeginPath(c);
//    CGContextSetLineWidth(c, 1.0);
//    CGContextMoveToPoint(c, beginPoint.x, beginPoint.y);
//    CGContextAddLineToPoint(c, endPoint.y, endPoint.y);
//    CGContextStrokePath(c);
//    CGContextRestoreGState(c);
}

@end
