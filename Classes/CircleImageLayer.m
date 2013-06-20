#import "CircleImageLayer.h"

@implementation CircleImageLayer {
    

    CGFloat _radius;
    CGMutablePathRef circlePath;
}

@dynamic radius;


-(id)initWithRadius:(CGFloat)theRadius {
    
    if (self == [self init]) {
        _radius = theRadius;
        self.frame = CGRectMake(0, 0, theRadius * 2 + ImageLayerDefaultStrokeWidth, theRadius * 2 + ImageLayerDefaultStrokeWidth);
        
//        [self drawBackgroundBorderLayer];
//        [self drawImageHostingLayer];
    }
    return self;
}

-(id)init {
    if (self == [super init]) {
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}

-(id)initWithImage:(UIImage *)theImage radius:(CGFloat)theRadius {
    
    if (self == [self initWithRadius:theRadius]) {
        _image = theImage;
//        [self drawImageInHostingLayer];
    }
    
    return self;
}

-(id)initWithLayer:(id)layer {
    if (self = [super initWithLayer:layer]) {
        if ([layer isKindOfClass:[CircleImageLayer class]]) {
            CircleImageLayer *imageLayer = (CircleImageLayer *)layer;
            self.image = imageLayer.image;
        }
    }
    return self;
}

-(CAAnimation *)makeAnimationForKey:(NSString *)key {
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    if ([key isEqualToString:@"radius"]) {
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
        
        anim.fromValue = [[self presentationLayer] valueForKey:key];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        anim.duration = 2.0;
    }
    return animGroup;
}


-(id<CAAction>)actionForKey:(NSString *)event {
    if ([event isEqualToString:@"radius"]) {
        return [self makeAnimationForKey:event];
    }
    return [super actionForKey:event];
}

//-(void)setRadius:(CGFloat)radius {
//    _radius = radius
//}

+(BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"transform"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

-(void)setImage:(UIImage *)image {
    _image = image;
    [self setNeedsDisplay];
}


-(void)drawInContext:(CGContextRef)ctx {
    
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);

    CGFloat height = self.bounds.size.height;
    CGContextTranslateCTM(ctx, 0.0, height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, center.x, center.y);
    
    CGContextAddArc(ctx, center.x, center.y, _radius, 0, M_PI * 2, 1);
    CGContextClosePath(ctx);
    
    CGContextSaveGState(ctx);
    CGContextClip(ctx);
    CGPathDrawingMode drawingMode;
    
    if (_image != nil) {
        
        CGSize imgSize = _image.size;
        CGFloat scale = MAX((_radius * 2) / imgSize.width, (_radius * 2) / imgSize.height);
        CGFloat imageWidth = _image.size.width * scale;
        CGFloat imageHeight = _image.size.height * scale;
        NSLog(@"Radius: %f", _radius);
        CGRect imgRect;
        
        if (imageWidth > imageHeight) {
            imgRect = CGRectMake(_radius - imageWidth / 2, 0, imageWidth, imageHeight);
        } else {
            imgRect = CGRectMake(0, _radius - imageHeight / 2, imageWidth, imageHeight);
        }
        
        CGContextDrawImage(ctx, imgRect, _image.CGImage);
        CGContextRestoreGState(ctx);
        drawingMode = kCGPathStroke;

    } else {
        CGContextSetFillColorWithColor(ctx, [UIColor grayColor].CGColor);
        drawingMode = kCGPathFillStroke;
    }
    CGContextAddArc(ctx, center.x, center.y, _radius - ImageLayerDefaultStrokeWidth / 2, 0, M_PI * 2, 1);
    CGContextSetLineWidth(ctx, ImageLayerDefaultStrokeWidth);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:.8].CGColor);
    CGContextDrawPath(ctx, drawingMode);
}

@end
