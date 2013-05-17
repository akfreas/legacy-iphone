@interface ProgressIndicator : CALayer

@property (assign) CGFloat startAngle;
@property (assign) CGFloat endAngle;
@property (assign) CGFloat strokeWidth;

@property (assign, nonatomic) UIColor *fillColor;
@property (assign, nonatomic) UIColor *strokeColor;

-(id)initWithCenterPoint:(CGPoint)point radius:(CGFloat)radius;
-(void)animate;
-(void)stopAnimating;

@end
