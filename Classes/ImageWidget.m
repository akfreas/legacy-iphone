#import "ImageWidget.h"


#define Ax	0
#define Ay	0
#define Bx	100
#define By	0
#define Cx	100
#define Cy	100
#define Dx	0
#define Dy	100
#define Ex	50
#define Ey	10
#define Fx	10
#define Fy	90
#define Gx	90
#define Gy	90
#define Hx	50
#define Hy	90
#define Ix	50
#define Iy	100


@implementation ImageWidget {
    
    UIImage *largeImage;
    UIImage *smallImage;
    
}


-(id)initWithSmallImage:(UIImage *)theSmallImage largeImage:(UIImage *)theLargeImage {
    self = [self initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    if (self) {
        largeImage = theLargeImage;
        smallImage = theSmallImage;
        _angle = 135;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}



-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    return self;
}

-(void)setAngle:(CGFloat)angle {
    _angle = angle;
    [self setNeedsDisplay];
}



-(void)drawRect:(CGRect)rect {
    
    
    CGSize imgSize = largeImage.size;
    CGSize viewSize = rect.size;
    CGRect imgRect;
    
    CGFloat scale = MIN(viewSize.width / imgSize.width, viewSize.height / imgSize.height);
    imgRect = CGRectMake(0, 0, largeImage.size.width * scale, largeImage.size.height * scale);
    
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
    
    
    
    
    CGContextDrawImage(context, imgRect, [largeImage CGImage]);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
//    CGContextMoveToPoint(context, imgRect.size.width, imgRect.size.height);
    CGSize smImgSize = smallImage.size;
    scale = MIN(50 / smImgSize.width, 50 / smImgSize.height);
    
    
    CGPoint arcCenter = CGPointMake((imgRect.size.width / 2) - largeArcRadius * cos(_angle * M_PI/180), imgRect.size.height / 2 -  largeArcRadius * sin(_angle * M_PI / 180));
    CGFloat smImgWidth = smallImage.size.width * scale;
    CGFloat smImgHeight = smallImage.size.height * scale;
    CGRect smImgRect = CGRectMake(arcCenter.x - smImgWidth / 2, arcCenter.y - smImgHeight / 2, smImgWidth, smImgHeight);
    CGContextAddArc(context, arcCenter.x, arcCenter.y, (MIN(smImgSize.height, smImgSize.width) * scale) / 2, 0, 2*M_PI, 1);
    CGContextClip(context);
    CGContextDrawImage(context, smImgRect, smallImage.CGImage);
    CGContextRestoreGState(context);
    
    
}

@end
