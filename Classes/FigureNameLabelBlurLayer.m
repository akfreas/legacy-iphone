#import <GPUImage/GPUImage.h>
#import "FigureNameLabelBlurLayer.h"
#import "UIImage+StackBlur.h"

@implementation FigureNameLabelBlurLayer {
    
    NSString *nameString;
    UILabel *nativeLabel;
    UIImageView *labelImageView;
    UIImage *labelImage;
    CIImage *labelCiImage;
    
    GPUImageGaussianBlurFilter *filter;
    GPUImagePicture *pic;
    
    CGFloat initialBlur;
}

-(id)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        nameString = string;


        self.frame = CGRectMake(0, 0, 320, 60);
        initialBlur = 10;
        self.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = [UIColor redColor];
//        [self addSubview:nativeLabel];

        filter = [[GPUImageGaussianBlurFilter alloc] init];
        filter.blurSize = initialBlur;
        labelImage = [self drawStringInContext:nil];
        pic = [[GPUImagePicture alloc] initWithImage:labelImage];
        
        [pic addTarget:filter];
        labelImageView = [[UIImageView alloc] initWithImage:labelImage];
        labelImageView.frame = self.bounds;
        [self addSubview:labelImageView];
        [self blurLabelWithRadius:initialBlur];
    }
    
    return self;
}

-(void)drawRect:(CGRect)rect {
 
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
//    [self drawStringInContext:nil];
}
-(UIImage *)drawStringInContext:(CGContextRef)ctcx {
    
    CGFloat actualFontSize;

    CGSize nameLabelSize = [nameString sizeWithFont:[UIFont fontWithName:@"Georgia" size:60] minFontSize:12 actualFontSize:&actualFontSize forWidth:self.bounds.size.width - 20 lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect nameFrame = CGRectMake(0, 0, nameLabelSize.width, nameLabelSize.height);
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 2.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(ctx, 0.0, self.frame.size.height);
//    CGContextScaleCTM(ctx, 2.0, -2.0);
    
    CGContextSetLineWidth(ctx, 1.0);
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddRect(ctx, self.bounds);
    CGContextDrawPath(ctx, kCGPathFill);
    
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    
    [nameString drawAtPoint:nameFrame.origin forWidth:nameFrame.size.width withFont:[UIFont fontWithName:@"Georgia" size:12] fontSize:actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentNone];
//    CGContextSaveGState(ctx);
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 2.0);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();

//    CGContextRelease(ctx);
//    CGContextRestoreGState(ctx);
    
    
    
    CGImageRef ref = CGBitmapContextCreateImage(ctx);
//    CGContextStrokeRect(ctx, CGRectMake(0, 0, 10, 10));
    UIImage *img = [UIImage imageWithCGImage:ref];
//    UIImage *img = [UIImage imageNamed:@"icon.png"];
    return img;
}

-(void)blurLabelWithRadius:(CGFloat)radius {
    if (labelCiImage == nil) {
        labelCiImage = [CIImage imageWithCGImage:labelImage.CGImage];
    }
    labelImageView.image = [labelImage stackBlur:radius];
    
}

-(void)setBlurFactor:(CGFloat)blurFactor {
    _blurFactor = MAX(0, initialBlur + blurFactor);
    [self blurLabelWithRadius:_blurFactor];
//    [self addSubview:nativeLabel];

}


@end

