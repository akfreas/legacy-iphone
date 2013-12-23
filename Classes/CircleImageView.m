#import "CircleImageView.h"
#import "CircleImageLayer.h"

@implementation CircleImageView {
    
    CircleImageLayer *circleLayer;
}


+(Class)layerClass {
    return [CircleImageLayer class];
}

-(id)initWithImage:(UIImage *)theImage radius:(CGFloat)theRadius {
    self = [super initWithFrame:CGRectMake(0, 0, theRadius * 2 + ImageLayerDefaultStrokeWidth, theRadius * 2 + ImageLayerDefaultStrokeWidth)];
    if (self) {
        self.radius = theRadius;
        self.backgroundColor = [UIColor clearColor];
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        [(CircleImageLayer *)self.layer setRadius:theRadius];
        [(CircleImageLayer *)self.layer setImage:theImage];
        [(CircleImageLayer *)self.layer setBorderWidth:ImageLayerDefaultStrokeWidth];
    }
    return self;
}

-(void)setImage:(UIImage *)image {
    [(CircleImageLayer *)self.layer setImage:image];
}

-(void)setRadius:(CGFloat)radius {
    _radius = radius;
    [(CircleImageLayer *)self.layer setRadius:radius];
}

-(void)setBorderWidth:(CGFloat)borderWidth {
    [(CircleImageLayer *)self.layer setBorderWidth:borderWidth];
}

-(void)setBorderColor:(UIColor *)borderColor {
    [(CircleImageLayer *)self.layer setBorderColor:borderColor.CGColor];
}

-(void)layoutSubviews {
    self.layer.frame = self.frame;
    [super layoutSubviews];
}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(self.radius, self.radius);
}

@end
