#import "ProgressIndicator.h"
#define DEG2RAD(angle) angle*M_PI/180.0


@implementation ProgressIndicator

@dynamic startAngle, endAngle;


-(id)initWithCenterPoint:(CGPoint)point radius:(CGFloat)radius {
    if (self = [self init]) {
        self.frame = CGRectMake(point.x - radius, point.y - radius, radius * 2, radius * 2);
        
        self.startAngle = DEG2RAD(270);
        self.endAngle = DEG2RAD(-90);
        self.strokeColor = [UIColor clearColor];
        self.fillColor = [UIColor whiteColor];
        self.strokeWidth = 1.25;
    }
    return self;
}

-(void)animate {
    self.startAngle = DEG2RAD(270);
    self.endAngle = DEG2RAD(270);
}


-(id)init {
    self = [super init];
    if (self) {
        
		self.fillColor = [UIColor grayColor];
        self.strokeColor = [UIColor blackColor];
		self.strokeWidth = 1.0;
		
		[self setNeedsDisplay];
    }
    return self;
}

-(id)initWithLayer:(id)layer {
    if (self = [super initWithLayer:layer]) {
        if ([layer isKindOfClass:[ProgressIndicator class]]) {
            ProgressIndicator *indicator = (ProgressIndicator *)layer;
            self.startAngle = indicator.startAngle;
            self.endAngle = indicator.endAngle;
            self.fillColor = indicator.fillColor;
            self.strokeWidth = indicator.strokeWidth;
            self.strokeColor = indicator.strokeColor;
        }
    }
    return self;
}

-(CAAnimation *)makeAnimationForKey:(NSString *)key {
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
    anim.fromValue = [[self presentationLayer] valueForKey:key];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = 4.0;
    return anim;
}

-(id<CAAction>)actionForKey:(NSString *)event {
    if([event isEqualToString:@"startAngle"] ||
       [event isEqualToString:@"endAngle"]) {
        return [self makeAnimationForKey:event];
    }
    
    return [super actionForKey:event];
}

+(BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"startAngle"] || [key isEqualToString:@"endAngle"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

-(void)drawInContext:(CGContextRef)ctx {
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = MIN(center.x, center.y);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, center.x, center.y);
    
    CGPoint p1 = CGPointMake(center.x + radius * cosf(self.startAngle), center.y + radius * sinf(self.startAngle));
    
    CGContextAddLineToPoint(ctx, p1.x, p1.y);
    
    int clockwise = self.startAngle > self.endAngle;
    
    CGContextAddArc(ctx, center.x, center.y, radius, self.startAngle, self.endAngle, clockwise);
    
    CGContextClosePath(ctx);
    
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
    CGContextSetLineWidth(ctx, self.strokeWidth);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

@end
