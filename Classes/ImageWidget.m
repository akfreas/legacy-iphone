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
        _angle = 100;
        _smallImageRadius = 20;
        _smallImageOffset = 5;
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

-(void)setSmallImageOffset:(CGFloat)smallImageOffset {
    _smallImageOffset = smallImageOffset;
    [self setNeedsDisplay];
}



-(void)drawRect:(CGRect)rect {
    
    
    CGSize imgSize = _largeImage.size;
    CGSize viewSize = rect.size;
    CGFloat radius = 40.0;
    CGFloat scale = MAX((radius * 2) / imgSize.width, (radius * 2) / imgSize.height);
    CGFloat imageWidth = _largeImage.size.width * scale;
    CGFloat imageHeight = _largeImage.size.height * scale;
    
    CGRect imgRect;
    
    if (imageWidth > imageHeight) {
        imgRect = CGRectMake(radius - imageWidth / 2, viewSize.height - imageHeight, imageWidth, imageHeight);
    } else {
        imgRect = CGRectMake(0, viewSize.height - imageHeight, imageWidth, imageHeight);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextFillRect(context, rect);
	CGFloat height = rect.size.height;
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSaveGState(context);
    CGFloat largeArcRadius = radius;
    CGContextAddArc(context, largeArcRadius, viewSize.height - largeArcRadius, largeArcRadius, 0, 2*M_PI, 1);
    CGContextClosePath(context);
    
    CGContextEOClip(context);
    
    
//    _smallImage = _largeImage;
    
    CGContextDrawImage(context, imgRect, [_largeImage CGImage]);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGSize smImgSize = _smallImage.size;
    scale = MAX((_smallImageRadius * 2) / smImgSize.width, (_smallImageRadius * 2) / smImgSize.height);
    
    
    CGPoint arcCenter = CGPointMake(viewSize.width  - largeArcRadius - (largeArcRadius - _smallImageOffset) * cos(_angle * M_PI/180), viewSize.height - largeArcRadius -  (largeArcRadius - _smallImageOffset) * sin(_angle * M_PI / 180));
    CGFloat smImgWidth = _smallImage.size.width * scale;
    CGFloat smImgHeight = _smallImage.size.height * scale;
    
    CGRect smImgRect;
    
    if (imageWidth > imageHeight) {
        smImgRect = CGRectMake(arcCenter.x -  smImgWidth /2, arcCenter.y - smImgHeight / 2, smImgWidth, smImgHeight);
    } else {
        smImgRect = CGRectMake(arcCenter.x - _smallImageRadius, arcCenter.y - _smallImageRadius, smImgWidth, smImgHeight);
    }
    
    CGContextAddArc(context, arcCenter.x, arcCenter.y, _smallImageRadius, 0, 2*M_PI, 1);
    CGContextClip(context);
    CGContextDrawImage(context, smImgRect, _smallImage.CGImage);
    CGContextRestoreGState(context);
}

@end
