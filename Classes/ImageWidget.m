#import "ImageWidget.h"



@implementation ImageWidget {
    
    CALayer *layer;
    
    CALayer *largeImageHostingLayer;
    CALayer *smallImageHostingLayer;
    
    CALayer *largeImageLayer;
    CALayer *smallImageLayer;
    
    CAShapeLayer *largeImageBorderLayer;
    CAShapeLayer *smallImageBorderLayer;
    
    CAShapeLayer *largeImageMask;
    CAShapeLayer *smallImageMask;
    
    CGMutablePathRef circlePath;
    
    UIImage *resizedLargeImage;
    
}


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
        _angle = 130;
        _smallImageRadius = 20;
        _largeImageRadius = 40;
        _smallImageOffset = 5;
        _expanded = NO;
        
        

        
        circlePath = CGPathCreateMutable();
        CGPathAddArc(circlePath, 0, _largeImageRadius, _largeImageRadius, _largeImageRadius, 0, 2*M_PI, 1);
        
//        largeImageLayer = [[CALayer alloc] init];
//        smallImageLayer = [[CALayer alloc] init];
//        [self.layer addSublayer:largeImageLayer];
//        [self.layer addSublayer:smallImageLayer];
        
        self.backgroundColor = [UIColor clearColor];
//        [self addGestureRecognizers];
    }
    return self;
}


#pragma mark setup

-(void)addGestureRecognizers {
}


#pragma mark getters/setters

-(void)setAngle:(CGFloat)angle {
    _angle = angle;
}

-(void)setSmallImageRadius:(CGFloat)smallImageRadius {
    _smallImageRadius = smallImageRadius;
}

-(void)setSmallImage:(UIImage *)smallImage {
    _smallImage = smallImage;
}

-(void)setLargeImage:(UIImage *)largeImage {
    _largeImage = largeImage;
    [self setNeedsDisplay];
}


-(void)setSmallImageOffset:(CGFloat)smallImageOffset {
    _smallImageOffset = smallImageOffset;
}

-(void)setExpanded:(BOOL)expanded {
    if (_expanded != expanded) {
    _expanded = !expanded;
        [self toggleExpand];
        _expanded = expanded;
    }
}

-(CGRect)largeImageFrame {
    return largeImageLayer.frame;
}

-(CALayer *)largeImageL {
    return largeImageLayer;
}

-(void)toggleExpand {
    
    NSLog(@"Expand!");

    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithDouble:0.2] forKey:kCATransactionAnimationDuration];

    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(2, 2);
    CGAffineTransform circleTransform = CGAffineTransformMakeScale(2, 2);
    CGRect circleFrame = CGRectMake(0, 0, _largeImageRadius * 2, _largeImageRadius * 2);
    
    if (_expanded) {
        scaleTransform = CGAffineTransformMakeScale(.5, .5);
        circleTransform = CGAffineTransformMakeScale(0, 0);
        largeImageLayer.mask.transform = largeImageBorderLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(1, 1));
        smallImageLayer.opacity = 1;
    } else {
        smallImageLayer.opacity = 0;
        largeImageLayer.mask.transform = largeImageBorderLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(2, 2));
    }
    
    
    circleFrame = CGRectMake(0, 0, _largeImageRadius * 2, _largeImageRadius * 2);
    
    CGRect largeImageFrame = CGRectApplyAffineTransform(circleFrame, circleTransform);

    
    CGFloat lgFrameWidthDiff = (largeImageFrame.size.width - circleFrame.size.width);
    CGFloat lgFrameHeightDiff = (largeImageFrame.size.height - circleFrame.size.height);
    
    largeImageLayer.frame = CGRectApplyAffineTransform(largeImageLayer.frame, scaleTransform);
    smallImageLayer.frame = CGRectMake(smallImageLayer.frame.origin.x + lgFrameWidthDiff, smallImageLayer.frame.origin.y + lgFrameHeightDiff, smallImageLayer.frame.size.width, smallImageLayer.frame.size.height);
    [CATransaction commit];
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect {
    
    if (largeImageBorderLayer == nil) {
        [self drawBackgroundBorderLayer];
        
    }
    
    if (largeImageLayer == nil) {
        [self drawLargeImageLayer];
        
    }
    
    if (_largeImage != nil) {
        [self drawLargeImage];
    } 
    if (_smallImage != nil && smallImageLayer == nil) {
        [self drawSmallImage];
    }
    
    

}

-(void)drawBackgroundBorderLayer {
    
    largeImageBorderLayer = [CAShapeLayer layer];
    largeImageBorderLayer.path = circlePath;
    largeImageBorderLayer.lineWidth = 3.0;
    largeImageBorderLayer.strokeColor = [UIColor whiteColor].CGColor;
    largeImageBorderLayer.fillColor = [UIColor grayColor].CGColor;
    largeImageBorderLayer.backgroundColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:largeImageBorderLayer];
}

-(void)drawLargeImageLayer {
    
    largeImageLayer = [[CALayer alloc] init];
    largeImageLayer.frame = CGRectMake(0, 0, _largeImageRadius, _largeImageRadius);
    [largeImageBorderLayer addSublayer:largeImageLayer];
}

-(void)drawLargeImage {
    
    
    CGSize imgSize = _largeImage.size;
    CGFloat scale = MAX((_largeImageRadius * 2) / imgSize.width, (_largeImageRadius * 2) / imgSize.height);
    CGFloat imageWidth = _largeImage.size.width * scale;
    CGFloat imageHeight = _largeImage.size.height * scale;
    
    CGRect imgRect;
    
    if (imageWidth > imageHeight) {
        imgRect = CGRectMake(_largeImageRadius - imageWidth / 2, 0, imageWidth, imageHeight);
    } else {
        imgRect = CGRectMake(0, _largeImageRadius - imageHeight / 2, imageWidth, imageHeight);
    }
    resizedLargeImage = [[UIImage alloc] init];
    UIGraphicsBeginImageContextWithOptions(imgRect.size, YES, 2.0);
    [_largeImage drawInRect:imgRect];
    resizedLargeImage = UIGraphicsGetImageFromCurrentImageContext();
    
    largeImageLayer.frame = CGRectMake(0, 0, imgRect.size.width, imgRect.size.height);
    largeImageLayer.contents = (__bridge id)(resizedLargeImage.CGImage);
    
//    [self addSubview:[[UIImageView alloc] initWithImage:resizedLargeImage]];
    
    largeImageMask = [[CAShapeLayer alloc] init];
    largeImageMask.path =  circlePath;
    
    largeImageLayer.mask  = largeImageMask;
//    largeImageLayer.zPosition = 6.0;
    
}

-(void)drawSmallImage {
    
    CGSize smImgSize = _smallImage.size;
    CGFloat scale = MAX((_smallImageRadius * 2) / smImgSize.width, (_smallImageRadius * 2) / smImgSize.height);
    
    
    CGPoint arcCenter = CGPointMake(_largeImageRadius - (_largeImageRadius - _smallImageOffset) * cos(_angle * M_PI/180), _largeImageRadius +  (_largeImageRadius - _smallImageOffset) * sin(_angle * M_PI / 180));
    NSLog(@"Arc center: %@", CGPointCreateDictionaryRepresentation(arcCenter));
    CGFloat smImgWidth = _smallImage.size.width * scale;
    CGFloat smImgHeight = _smallImage.size.height * scale;
    
    CGRect smImgRect;
    
    if (smImgWidth > smImgHeight) {
        smImgRect = CGRectMake(arcCenter.x -  smImgWidth / 2, arcCenter.y - smImgHeight / 2, smImgWidth, smImgHeight);
    } else {
        smImgRect = CGRectMake(arcCenter.x - _smallImageRadius, arcCenter.y - _smallImageRadius, smImgWidth, smImgHeight);
    }
    
    CGMutablePathRef smallCirclePath = CGPathCreateMutable();
    
    CGPathAddArc(smallCirclePath, 0, _smallImageRadius, _smallImageRadius, _smallImageRadius, 0, 2*M_PI, true);
    smallImageMask = [[CAShapeLayer alloc] init];
    smallImageMask.path = smallCirclePath;
    
    smallImageBorderLayer = [[CAShapeLayer alloc] init];
    smallImageBorderLayer.path = smallCirclePath;
    smallImageBorderLayer.lineWidth = 3.0;
    smallImageBorderLayer.opacity = 1;
    smallImageBorderLayer.fillColor = [UIColor clearColor].CGColor;
    smallImageBorderLayer.strokeColor = [UIColor whiteColor].CGColor;

    
    smallImageLayer = [[CALayer alloc] init];
    smallImageLayer.contents = (__bridge id)(_smallImage.CGImage);
    smallImageLayer.frame = CGRectMake(arcCenter.x - _smallImageRadius, arcCenter.y - _smallImageRadius, smImgWidth, smImgHeight);
    smallImageLayer.mask = smallImageMask;
    smallImageLayer.zPosition = 3.0;
    smallImageBorderLayer.zPosition = 4.0;
    [smallImageLayer addSublayer:smallImageBorderLayer];
    [self.layer addSublayer:smallImageLayer];
    
}

@end