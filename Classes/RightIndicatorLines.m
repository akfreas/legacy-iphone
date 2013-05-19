#import "RightIndicatorLines.h"
#import "Person.h"
#import "CircleImageLayer.h"

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
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setLineEndPoint:(CGPoint)lineEndPoint {
    _lineEndPoint = lineEndPoint;
    [self setNeedsDisplay];
}

-(void)setPerson:(Person *)person {
    _person = person;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (CGPointEqualToPoint(_lineEndPoint, CGPointZero) == false) {
        [self drawLines];
    }
    
    if (self.person != nil) {
        [self drawPersonInfo];
    }
}

-(void)drawPersonInfo {
        
    const int numPoints = 3;
    CGPoint points[numPoints] = {CGPointMake(_lineEndPoint.x, 40), CGPointMake(_lineEndPoint.x - 40, 40), CGPointMake(_lineEndPoint.x - 50, 80)};
        
    [path moveToPoint:points[0]];
    [path addLineToPoint:points[1]];
    [path stroke];
    [path moveToPoint:points[1]];
    [path addLineToPoint:points[2]];
    [path stroke];
    UIImage *thumb = [UIImage imageWithData:self.person.thumbnail];
    
    CircleImageLayer *imageLayer = [[CircleImageLayer alloc] initWithImage:thumb radius:20];
    
    CGFloat imageLayerSize = 20;
    imageLayer.frame = CGRectMake(points[1].x - imageLayerSize, points[1].y - imageLayerSize, imageLayerSize, imageLayerSize);
    [self.layer addSublayer:imageLayer];
             
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.string = self.person.fullName;

    
    CGPoint p2 = points[2];
    
    CGFloat fontSize = 12;
    CGSize textSize = [self.person.fullName sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12]];
    
    textLayer.contentsScale = [[UIScreen mainScreen] scale];
    textLayer.fontSize = fontSize;
    textLayer.foregroundColor = [UIColor blackColor].CGColor;
    textLayer.frame = CGRectMake(p2.x - textSize.width/2, p2.y - textSize.height/2, textSize.width, textSize.height);
//    textLayer.bounds = CGRectMake(0, 0, 100, 100);
    textLayer.masksToBounds = YES;
    
    [self.layer addSublayer:textLayer];

    
}

-(void)drawLines {
    
    path = [UIBezierPath bezierPath];
    
    path.lineWidth = 1.0;
    path.lineJoinStyle = kCGLineJoinRound;
    
    CGFloat dash[2] = {3.0, 5.0};
    
    [path setLineDash:dash count:2 phase:0];
    [[UIColor colorWithRed:0 green:0 blue:1 alpha:.35] setStroke];
    
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(_lineEndPoint.x, 20)];
    [path addLineToPoint:_lineEndPoint];

    [path stroke];
}

@end
