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
        self.backgroundColor = [UIColor clearColor];
        [(CircleImageLayer *)self.layer setRadius:theRadius];
        [(CircleImageLayer *)self.layer setImage:theImage];
    }
    return self;
}

-(void)layoutSubviews { 
    self.layer.frame = self.frame;
}

@end
