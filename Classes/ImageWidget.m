#import "ImageWidget.h"
#import "CircleImageView.h"



@implementation ImageWidget {
    
    CALayer *layer;
    CAShapeLayer *smallImageBorderLayer;
    CircleImageView *largeCircleImage;
    CircleImageView *smallCircleImage;
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
    
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _angle = 130;
        _smallImageOffset = 5;
        _smallImageRadius = PersonPhotoRadius;
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
    [self setNeedsLayout];
}

-(void)setLargeImage:(UIImage *)largeImage {
    _largeImage = largeImage;
    largeCircleImage.image = largeImage;
    [self setNeedsLayout];
}

-(void)setLargeImageBorderColor:(UIColor *)largeImageBorderColor {
    _largeImageBorderColor = largeImageBorderColor;
    largeCircleImage.borderColor = largeImageBorderColor;
}

-(void)setSmallImageBorderColor:(UIColor *)smallImageBorderColor {
    _smallImageBorderColor = smallImageBorderColor;
    smallCircleImage.borderColor = smallImageBorderColor;
}

-(void)setSmallImageBorderWidth:(CGFloat)smallImageBorderWidth {
    _smallImageBorderWidth = smallImageBorderWidth;
    smallCircleImage.borderWidth = smallImageBorderWidth;
}

-(void)setLargeImageBorderWidth:(CGFloat)largeImageBorderWidth {
    _largeImageBorderWidth = largeImageBorderWidth;
    largeCircleImage.borderWidth = largeImageBorderWidth;
}

-(void)setSmallImageOffset:(CGFloat)smallImageOffset {
    _smallImageOffset = smallImageOffset;
}

-(CGRect)largeImageFrame {
    return largeCircleImage.frame;
}

-(void)layoutSubviews {
    
    if (largeCircleImage == nil) {
        largeCircleImage = [[CircleImageView alloc] initWithImage:_largeImage radius:_largeImageRadius];
        largeCircleImage.borderColor = self.largeImageBorderColor;
        largeCircleImage.borderWidth = self.largeImageBorderWidth;
        [self addSubview:largeCircleImage];
        UIBind(largeCircleImage);
        [self addConstraintWithVisualFormat:@"V:|[largeCircleImage]|" bindings:BBindings];
        [self addConstraintWithVisualFormat:@"H:|[largeCircleImage]|" bindings:BBindings];
    }
    
    largeCircleImage.image = _largeImage;
    [self drawSmallImage];
    [super layoutSubviews];

}

-(void)drawSmallImage {
    
    if (_smallImage != nil) {
        
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
        if (smallCircleImage == nil) {
            smallCircleImage = [[CircleImageView alloc] initWithImage:_smallImage radius:_smallImageRadius];
            [self addSubview:smallCircleImage];
        } else {
            smallCircleImage.hidden = NO;
            smallCircleImage.image = _smallImage;
        }
        
        smallCircleImage.borderWidth = self.smallImageBorderWidth;
        smallCircleImage.borderColor = self.smallImageBorderColor;
        smallCircleImage.frame = smImgRect;
    } else {
        smallCircleImage.hidden = YES;
    }
}

@end