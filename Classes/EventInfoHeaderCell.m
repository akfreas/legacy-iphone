#import "EventInfoHeaderCell.h"
#import "CircleImageView.h"
#import "Event.h"
#import "Figure.h"
#import "ImageDownloadUtil.h"
#import "FigureNameLabelBlurLayer.h"
#import "HeaderCellLine.h"

#import <CoreImage/CoreImage.h>

@implementation EventInfoHeaderCell {
    
    Event *event;
//    UIView *mainImageView;
    CircleImageView *mainImageView;
    CircleImageView *personImageView;
    HeaderCellLine *cellLine;
    UIImage *mainImage;
    UIImage *blurImage;
    UIImageView *blurImageView;
}

-(id)initWithEvent:(Event *)anEvent {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifierForHeader];
    
    if (self) {
        event = anEvent;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

        self.contentView.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor lightGrayColor];
        [self fetchFigureProfilePic];
    }
    
    return self;
}
-(void)addImageBlurView {
    blurImageView = [[UIImageView alloc] initWithImage:blurImage];
    blurImageView.alpha = 0;
    [self.contentView insertSubview:blurImageView belowSubview:cellLine];
//    [self.contentView addSubview:blurImageView];
    UIBind(blurImageView);
    [self.contentView addConstraintWithVisualFormat:@"H:|[blurImageView]|" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|[blurImageView]|" bindings:BBindings];
    [UIView animateWithDuration:0.5f animations:^{
        blurImageView.alpha = 1;
    }];
}

-(void)drawBackgroundBlurImage {
    
    dispatch_queue_t queue = dispatch_queue_create("com.legacyapp.imagequeue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        CGFloat transform = self.contentView.frame.size.width / mainImage.size.width;
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *image = [CIImage imageWithCGImage:mainImage.CGImage];
        CGAffineTransform cgTransform = CGAffineTransformMakeScale(transform, transform);
    //    cgTransform = CGAffineTransformTranslate(cgTransform, -1, 0);
        image = [image imageByApplyingTransform:cgTransform];
        CIFilter *gaussianFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [gaussianFilter setValue:image forKey:kCIInputImageKey];
        [gaussianFilter setValue:@"6" forKey:kCIInputRadiusKey];
        
        
        CIImage *result = [gaussianFilter valueForKey:kCIOutputImageKey];
        CIFilter *bwFilter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, result, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.1], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil];
        result = [bwFilter valueForKey:kCIOutputImageKey];
        CGRect extent = [result extent];
        CGRect ourBounds = CGRectMakeFrameForDeadCenterInRect(extent, self.intrinsicContentSize);
        ourBounds = CGRectOffset(ourBounds, extent.origin.y, 0);
        CGImageRef imgRef = [context createCGImage:result fromRect:ourBounds];
        blurImage = [UIImage imageWithCGImage:imgRef];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addImageBlurView];
        });
    });

}

#pragma mark Accessors

-(CGSize)intrinsicContentSize {
    return CGSizeMake(320.0f, 200.0f);
}

-(CGPoint)pointForLines {
    
    CGPoint newPoint = CGPointMake(CGRectGetMaxX(mainImageView.frame), mainImageView.frame.origin.y + mainImageView.frame.size.height / 2);
    
    return newPoint;
}

#pragma mark View Helper Methods


-(void)drawMainCircleImage {
    
    if (mainImageView == nil) {
//        mainImageView = [[UIView alloc] initWithFrame:CGRectZero];
        mainImageView = [[CircleImageView alloc] initWithImage:mainImage radius:60.0f];
        mainImageView.borderWidth = PersonPhotoBorderWidth;
        mainImageView.borderColor = PersonPhotoBorderColor;
        [self.contentView insertSubview:mainImageView aboveSubview:cellLine];
    } else {
        mainImageView.image = mainImage;
    }
    CGRect imageRect = CGRectMakeFrameForDeadCenterInRect(self.contentView.frame, mainImageView.frame.size);
    mainImageView.frame = CGRectOffset(imageRect, -50, 0);
    //    UIBind(mainImageView);
//    [mainImageView autoCenterInSuperview];
//    [self.contentView addConstraintWithVisualFormat:@"H:|[mainImageView(100)]|" bindings:BBindings];
//    [self.contentView addConstraintWithVisualFormat:@"V:|-[mainImageView(100)]-|" bindings:BBindings];
}

-(void)addLine {
    cellLine = [[HeaderCellLine alloc] initWithFrame:self.contentView.bounds numberOfItems:[event.figure.events count]];
    [self.contentView addSubview:cellLine];
}

-(void)fetchFigureProfilePic {
    
    [[ImageDownloadUtil sharedInstance] fetchAndSaveImageForFigure:event.figure completion:^(UIImage *theImage) {
        mainImage = theImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLine];
            [self drawMainCircleImage];
            [self drawBackgroundBlurImage];
        });
    }];
}

@end
