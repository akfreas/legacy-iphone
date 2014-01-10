#import "FigureTimelineTopCellLine.h"

@implementation FigureTimelineTopCellLine {
    NSInteger itemCount;
}

- (id)initWithFrame:(CGRect)frame numberOfItems:(NSInteger)itemC {
    self = [super initWithFrame:frame];
    if (self) {
        itemCount = itemC;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setNumberOfItems:(NSInteger)numberOfItems {
    _numberOfItems = numberOfItems;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = EventHeaderCellLineStrokeWidth;
    path.lineCapStyle = kCGLineCapRound;
    
    [[UIColor whiteColor] setStroke];
    CGFloat yAxis = rect.size.height / 2;
    CGPoint originPoint = CGPointMake(rect.size.width, yAxis);
    [path moveToPoint:originPoint];
    CGFloat endXPoint = 30;
    CGPoint leftPoint = CGPointMake(endXPoint, yAxis);
    [path addLineToPoint:leftPoint];
    CGPoint curvePoint = CGPointMake(leftPoint.x - 10, leftPoint.y + 10);
    [path addCurveToPoint:curvePoint controlPoint1:CGPointMake(leftPoint.x - 6, leftPoint.y) controlPoint2:CGPointMake(curvePoint.x, curvePoint.y - 6) ];// CGPointMake(leftPoint.y - 10, leftPoint.y)];
    [path addLineToPoint:CGPointMake(curvePoint.x, self.bounds.size.height)];
    [path stroke];
    
    [[UIColor whiteColor] setFill];
    NSDictionary *textAttrs = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : LegacyPointSummaryFont};
    NSString *plural = itemCount > 1 ? @"s" : @"";
    NSString *legacyPointString = [NSString stringWithFormat:@"%i Legacy Point%@", itemCount, plural];
    [legacyPointString drawAtPoint:CGPointMake(originPoint.x - 130, originPoint.y - 20) withAttributes:textAttrs];
    
}

@end
