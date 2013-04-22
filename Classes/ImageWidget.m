#import "ImageWidget.h"

@implementation ImageWidget


-(id)initWithSmallImage:(UIImage *)theSmallImage largeImage:(UIImage *)theLargeImage {
    self = [self init];
    
    if (self) {
        _largeImage = theLargeImage;
        _smallImage = theSmallImage;
    }
    return self;
}


-(id)init {
    
    self = [super initWithFrame:CGRectMake(0, 0, 100, 100)];
    if (self) {
        _angle = 135;
        _smallImageRadius = 50;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setAngle:(CGFloat)angle {
    _angle = angle;
    [self setNeedsDisplay];
}

-(void)setSmallImageRadius:(CGFloat)smallImageRadius {
    _smallImageRadius = smallImageRadius;
    [self setNeedsDisplay];
}

-(void)setSmallImage:(UIImage *)smallImage {
    _smallImage = smallImage;
    [self setNeedsDisplay];
}

-(void)setLargeImage:(UIImage *)largeImage {
    _largeImage = largeImage;
    [self setNeedsDisplay];
}



-(void)drawRect:(CGRect)rect {
    
    
    CGSize imgSize = _largeImage.size;
    CGSize viewSize = rect.size;
    CGRect imgRect;
    
    CGFloat scale = MIN(viewSize.width / imgSize.width, viewSize.height / imgSize.height);
    imgRect = CGRectMake(0, 0, _largeImage.size.width * scale, _largeImage.size.height * scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextFillRect(context, rect);
	CGFloat height = rect.size.height;
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSaveGState(context);
    CGFloat largeArcRadius = imgRect.size.width / 2;
    CGContextAddArc(context, imgRect.size.width / 2, imgRect.size.height / 2, largeArcRadius, 0, 2*M_PI, 1);
    CGContextClosePath(context);
    
    CGContextEOClip(context);
    
    
//    _smallImage = _largeImage;
    
    CGContextDrawImage(context, imgRect, [_largeImage CGImage]);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGSize smImgSize = _smallImage.size;
    scale = MIN(_smallImageRadius / smImgSize.width, _smallImageRadius / smImgSize.height);
    
    
    CGPoint arcCenter = CGPointMake((imgRect.size.width / 2) - largeArcRadius * cos(_angle * M_PI/180), imgRect.size.height / 2 -  largeArcRadius * sin(_angle * M_PI / 180));
    CGFloat smImgWidth = _smallImage.size.width * scale;
    CGFloat smImgHeight = _smallImage.size.height * scale;
    CGRect smImgRect = CGRectMake(arcCenter.x - smImgWidth / 2, arcCenter.y - smImgHeight / 2, smImgWidth, smImgHeight);
    CGContextAddArc(context, arcCenter.x, arcCenter.y, (MIN(smImgSize.height, smImgSize.width) * scale) / 2, 0, 2*M_PI, 1);
    CGContextClip(context);
    CGContextDrawImage(context, smImgRect, _smallImage.CGImage);
    CGContextRestoreGState(context);
}

@end
