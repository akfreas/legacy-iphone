#import "ImageWidget.h"
#import "CircleImageLayer.h"



@implementation ImageWidget {
    
    CALayer *layer;
    CAShapeLayer *smallImageBorderLayer;
    CircleImageLayer *largeCircleImage;
    CircleImageLayer *smallCircleImage;
    CAShapeLayer *smallImageMask;
    
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
    
    self = [super initWithFrame:CGRectMake(0, 0, ImageWidgetInitialWidth, ImageWidgetInitialHeight)];
    if (self) {
        _angle = 130;
        _smallImageRadius = 20;
        _largeImageRadius = ImageWidgetInitialWidth / 2 - ImageLayerDefaultStrokeWidth / 2;
        _smallImageOffset = 5;
        _expanded = NO;
        
        self.backgroundColor = [UIColor clearColor];
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
    return largeCircleImage.frame;
}

-(void)toggleExpand {
    
    NSLog(@"Expand!");

    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithDouble:0.2] forKey:kCATransactionAnimationDuration];

    CGAffineTransform circleTransform = CGAffineTransformMakeScale(2, 2);
    CGRect circleFrame = CGRectMake(0, 0, _largeImageRadius * 2, _largeImageRadius * 2);
    
    CGAffineTransform trans;
    if (_expanded == YES) {
        circleTransform = CGAffineTransformMakeScale(0, 0);
        
        trans = CGAffineTransformMakeScale(1, 1);
        
        largeCircleImage.transform = CATransform3DMakeAffineTransform(trans);
        trans = CGAffineTransformMakeScale(.5, .5); /// HAX NONONO
        smallCircleImage.opacity = 1;
        largeCircleImage.anchorPoint = CGPointMake(.5, .5);
    } else {
        largeCircleImage.anchorPoint = CGPointMake(.25, .25);
        smallCircleImage.opacity = 0;
        
        trans = CGAffineTransformMakeScale(2, 2);
        largeCircleImage.transform = CATransform3DMakeAffineTransform(trans);
    }
    
    self.frame = CGRectApplyAffineTransform(self.frame, trans);
    circleFrame = CGRectMake(0, 0, _largeImageRadius * 2, _largeImageRadius * 2);
    
    CGRect largeImageFrame = CGRectApplyAffineTransform(circleFrame, circleTransform);

    
    CGFloat lgFrameWidthDiff = (largeImageFrame.size.width - circleFrame.size.width);
    CGFloat lgFrameHeightDiff = (largeImageFrame.size.height - circleFrame.size.height);
    
    smallCircleImage.frame = CGRectMake(smallCircleImage.frame.origin.x + lgFrameWidthDiff, smallCircleImage.frame.origin.y + lgFrameHeightDiff, smallCircleImage.frame.size.width, smallCircleImage.frame.size.height);
    [CATransaction commit];
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect {
    

    if (largeCircleImage == nil) {
        largeCircleImage = [[CircleImageLayer alloc] initWithRadius:_largeImageRadius];
//        largeCircleImage.frame = frame
        [self.layer addSublayer:largeCircleImage];
    }
    
    if (_largeImage != nil) {
        largeCircleImage.image = _largeImage;
    } 
    if (_smallImage != nil && smallCircleImage == nil) {
        [self drawSmallImage];
    }
}

-(void)drawSmallImage {
    
    CGSize smImgSize = _smallImage.size;
    CGFloat scale = MAX((_smallImageRadius * 2) / smImgSize.width, (_smallImageRadius * 2) / smImgSize.height);
    
    
    CGPoint arcCenter = CGPointMake(_largeImageRadius - (_largeImageRadius - _smallImageOffset) * cos(_angle * M_PI/180), _largeImageRadius +  (_largeImageRadius - _smallImageOffset) * sin(_angle * M_PI / 180));
    
    CGFloat smImgWidth = _smallImage.size.width * scale;
    CGFloat smImgHeight = _smallImage.size.height * scale;
    
    CGRect smImgRect;
    
    if (smImgWidth > smImgHeight) {
        smImgRect = CGRectMake(arcCenter.x -  smImgWidth / 2, arcCenter.y - smImgHeight / 2, smImgWidth, smImgHeight);
    } else {
        smImgRect = CGRectMake(arcCenter.x - _smallImageRadius, arcCenter.y - _smallImageRadius, smImgWidth, smImgHeight);
    }
    smallCircleImage = [[CircleImageLayer alloc] initWithImage:_smallImage radius:_smallImageRadius];
    smallCircleImage.frame = smImgRect;

    [self.layer addSublayer:smallCircleImage];
    
}

@end