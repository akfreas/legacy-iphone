#import "CircleImageLayer.h"

@implementation CircleImageLayer {
    
    CALayer *imageHostingLayer;
    CAShapeLayer *mask;
    CAShapeLayer *borderLayer;
    CGFloat radius;
    CGMutablePathRef circlePath;
}

-(id)initWithRadius:(CGFloat)theRadius {
    
    if (self == [super init]) {
        radius = theRadius;
        self.frame = CGRectMake(0, 0, theRadius, theRadius);
        circlePath = CGPathCreateMutable();
        CGPathAddArc(circlePath, 0, radius, radius, radius, 0, 2*M_PI, 1);
        
        [self drawBackgroundBorderLayer];
        [self drawImageHostingLayer];
    }
    return self;
}

-(id)initWithImage:(UIImage *)theImage radius:(CGFloat)theRadius {
    
    if (self == [self initWithRadius:theRadius]) {
        _image = theImage;
        [self drawImageInHostingLayer];
    }
    
    return self;
}


-(void)setImage:(UIImage *)image {
    _image = image;
    [self drawImageInHostingLayer];
}

-(void)drawImageHostingLayer {
    
    imageHostingLayer = [CALayer layer];
    imageHostingLayer.frame = CGRectMake(0, 0, radius, radius);
    [borderLayer addSublayer:imageHostingLayer];
}

-(void)drawBackgroundBorderLayer {
    
    borderLayer = [CAShapeLayer layer];
    borderLayer.path = circlePath;
    borderLayer.lineWidth = 3.0;
    borderLayer.strokeColor = [UIColor whiteColor].CGColor;
    borderLayer.fillColor = [UIColor grayColor].CGColor;
    borderLayer.backgroundColor = [UIColor redColor].CGColor;
    [self addSublayer:borderLayer];
}

-(void)drawImageInHostingLayer {
    
    
    CGSize imgSize = _image.size;
    CGFloat scale = MAX((radius * 2) / imgSize.width, (radius * 2) / imgSize.height);
    CGFloat imageWidth = _image.size.width * scale;
    CGFloat imageHeight = _image.size.height * scale;
    
    CGRect imgRect;
    
    if (imageWidth > imageHeight) {
        imgRect = CGRectMake(radius - imageWidth / 2, 0, imageWidth, imageHeight);
    } else {
        imgRect = CGRectMake(0, radius - imageHeight / 2, imageWidth, imageHeight);
    }
    UIGraphicsBeginImageContextWithOptions(imgRect.size, YES, 2.0);
    [_image drawInRect:imgRect];
    UIImage *resizedLargeImage = UIGraphicsGetImageFromCurrentImageContext();
    
    imageHostingLayer.frame = CGRectMake(0, 0, imgRect.size.width, imgRect.size.height);
    imageHostingLayer.contents = (__bridge id)(resizedLargeImage.CGImage);
    
    mask = [[CAShapeLayer alloc] init];
    mask.path =  circlePath;
    
    imageHostingLayer.mask  = mask;
}

@end
