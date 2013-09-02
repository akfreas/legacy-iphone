#import "RightIndicatorLines.h"
#import "Person.h"
#import "CircleImageLayer.h"

@implementation RightIndicatorLines {
    
    UIBezierPath *path;
}

+(CGRect)rectForStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    
    CGRect newRect = CGRectZero;
    
    CGPoint newOrigin = CGPointZero;
    CGSize newSize = CGSizeZero;
    
    newOrigin.x = MIN(startPoint.x, endPoint.x);
    newOrigin.y = MIN(startPoint.y, endPoint.y);
    
    newSize.width = MAX(startPoint.x, endPoint.x) - newOrigin.x;
    newSize.height = MAX(startPoint.y, endPoint.y) - newOrigin.y;
    
    newRect.origin = newOrigin;
    newRect.size = newSize;
    
    return newRect;
}

-(id)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    
    if (self = [self initWithFrame:[RightIndicatorLines rectForStartPoint:startPoint endPoint:endPoint]]) {
        _lineStartPoint = CGPointZero;
        _lineEndPoint = CGPointMake(self.frame.size.width/1.35, self.frame.size.height);
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
    
    if (self.person.thumbnail != nil) {
        [self drawPersonInfo];
    }
}


-(void)drawLines {
    
    path = [UIBezierPath bezierPath];
    
    path.lineWidth = 1.0;
    path.lineJoinStyle = kCGLineJoinRound;
    
    CGFloat dash[2] = {3.0, 5.0};
    
    [path setLineDash:dash count:2 phase:0];
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:.35] setStroke];
    
    [path moveToPoint:_lineStartPoint];
//    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:_lineStartPoint];
    [path addLineToPoint:CGPointMake(_lineEndPoint.x, 20)];
    [path addLineToPoint:_lineEndPoint];
    
    [path stroke];
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
        
    imageLayer.frame = CGRectMake(points[1].x - imageLayer.bounds.size.height / 2, points[1].y - imageLayer.bounds.size.width / 2, imageLayer.bounds.size.width, imageLayer.bounds.size.height);
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


@end
