#import "ScrollViewStickLines.h"
#import "FigureRow.h"
#import "AgeIndicatorView.h"

@implementation ScrollViewStickLines

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    if (_figureRowArray != nil) {

        UIBezierPath *aPath = [UIBezierPath bezierPath];
        aPath.lineCapStyle = kCGLineCapRound;
        aPath.lineJoinStyle = kCGLineJoinRound;
        aPath.lineWidth = 2.0;
        CGFloat originX = 5.0;
        CGPoint originPoint = CGPointMake(originX, 0.0);
        [aPath moveToPoint:originPoint];
        for (FigureRow *row in _figureRowArray) {
            AgeIndicatorView *indicatorView = row.ageIndicator;
//            [aPath addLineToPoint:[self convertPoint:indicatorView.center fromView:indicatorView]];
            NSArray *arrayOfLabels = [indicatorView.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag > 0"]];
            NSArray *sortedArrayOfLabels = [arrayOfLabels sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
                if (view1.tag > view2.tag) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedDescending;
                }
            }];
            CGPoint lastMajorTick = originPoint;
            for (UILabel *label in sortedArrayOfLabels) {
                CGPoint labelCenter = [self convertPoint:CGPointMake(CGRectGetMinX(label.frame), CGRectGetMidY(label.frame)) fromView:indicatorView.view];
                
                CGFloat formattedYValue = labelCenter.y - ((int)labelCenter.y % 6);
                CGPoint formattedLabelCenter = CGPointMake(labelCenter.x, formattedYValue);
                CGPoint labelOffset = CGPointMake(originX, formattedYValue);
                
                [aPath addLineToPoint:labelOffset];
                [aPath addLineToPoint:formattedLabelCenter];
                [aPath addLineToPoint:labelOffset];
                [self addMinorTickMarksFromPoint:lastMajorTick toPoint:labelOffset];
                lastMajorTick = labelOffset;
                NSLog(@"Label text: %@", label.text);
            }
        }
        
        [aPath stroke];
    }
}

-(void)addMinorTickMarksFromPoint:(CGPoint)originPoint toPoint:(CGPoint)destPoint {
    CGFloat spacing = 6.0;
    CGFloat lineHeight = 7.0;
    for (int increment=originPoint.y; increment<=destPoint.y; increment+=(int)spacing) {
        
        CGPoint newPointX = CGPointMake(originPoint.x + lineHeight, increment);
        CGPoint newPointReturn = CGPointMake(originPoint.x, increment);
        
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextSaveGState(c);
        CGFloat black[4] = {0.0f, 0.0f, 0.0f, 1.0f};
        CGContextSetStrokeColor(c, black);
        CGContextBeginPath(c);
        CGContextSetLineWidth(c, 1.0);
        CGContextMoveToPoint(c, newPointReturn.x, newPointReturn.y);
        CGContextAddLineToPoint(c, newPointX.x, newPointX.y);
        CGContextStrokePath(c);
        CGContextRestoreGState(c);
    }
    
}

-(void)setFigureRowArray:(NSArray *)figureRowArray {
    _figureRowArray = figureRowArray;
    [self setNeedsDisplay];
}

@end
