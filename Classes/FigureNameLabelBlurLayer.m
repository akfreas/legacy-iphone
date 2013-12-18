#import "FigureNameLabelBlurLayer.h"
#import "UIImage+StackBlur.h"

@implementation FigureNameLabelBlurLayer {
    
    NSString *nameString;
    UILabel *nativeLabel;
    UIImageView *labelImageView;
    UIImage *labelImage;
    CIImage *labelCiImage;
    
    CGFloat initialBlur;
    CGFloat currentBlur;
}

-(id)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        nameString = string;

        
        self.frame = CGRectMake(0, 0, 320, 70);
        initialBlur = 13;
        currentBlur = initialBlur;
        self.backgroundColor = [UIColor clearColor];
        labelImage = [self drawStringInContext:nil];
        
        labelImageView = [[UIImageView alloc] initWithImage:labelImage];
        labelImageView.frame = self.bounds;
        [self addSubview:labelImageView];
        [self blurLabelWithRadius:initialBlur];
    }
    
    return self;
}

-(UIImage *)drawStringInContext:(CGContextRef)ctcx {
    
    CGFloat actualFontSize;

    CGSize nameLabelSize = [nameString sizeWithFont:[UIFont fontWithName:@"Cinzel-Regular" size:60] minFontSize:12 actualFontSize:&actualFontSize forWidth:self.bounds.size.width - 20 lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect nameFrame = CGRectMake(0, 0, nameLabelSize.width, nameLabelSize.height);
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 2.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(ctx, 1.0);
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddRect(ctx, self.bounds);
    CGContextDrawPath(ctx, kCGPathFill);
    
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGPoint textBeginPoint = CGPointMake(nameFrame.origin.x + 10, nameFrame.origin.y);
    [nameString drawAtPoint:textBeginPoint forWidth:nameFrame.size.width withFont:[UIFont fontWithName:@"Cinzel-Regular" size:12] fontSize:actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentNone];
    
    CGImageRef ref = CGBitmapContextCreateImage(ctx);

    UIImage *img = [UIImage imageWithCGImage:ref];
    return img;
}

-(void)blurLabelWithRadius:(CGFloat)radius {
    labelImageView.image = [labelImage stackBlur:radius];
    
}

-(void)setBlurFactor:(CGFloat)blurFactor {
    
    _blurFactor = MAX(0, initialBlur + blurFactor*.20);
    if (_blurFactor != currentBlur) {
        [self blurLabelWithRadius:_blurFactor];
    }
}


@end

