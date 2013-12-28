#import "FigureTimelineTopCell.h"
#import "ImageWidget.h"
#import "Event.h"
#import "Figure.h"
#import "Person.h"
#import "ImageDownloadUtil.h"
#import "FigureNameLabelBlurLayer.h"
#import "EventPersonRelation.h"
#import "FigureTimelineTopCellLine.h"

#import <CoreImage/CoreImage.h>

@implementation FigureTimelineTopCell {
    
    EventPersonRelation *relation;
    ImageWidget *imageWidget;
    FigureTimelineTopCellLine *cellLine;
    UIImage *mainImage;
    UIImage *blurImage;
    UIImageView *blurImageView;
}

-(id)initWithRelation:(EventPersonRelation *)aRelation {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifierForHeader];
    
    if (self) {
        relation = aRelation;
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
    
    CGPoint newPoint = CGPointMake(CGRectGetMaxX(imageWidget.frame), imageWidget.frame.origin.y + imageWidget.frame.size.height / 2);
    
    return newPoint;
}

#pragma mark View Helper Methods


-(void)drawMainCircleImage {
    
    if (imageWidget == nil) {
        imageWidget = [[ImageWidget alloc] initWithSmallImage:relation.person.thumbnailImage largeImage:mainImage];
        imageWidget.largeImageRadius = 60;
        imageWidget.smallImageRadius = 30;
        imageWidget.largeImageBorderWidth = PersonPhotoBorderWidth;
        imageWidget.largeImageBorderColor = PersonPhotoBorderColor;
        imageWidget.smallImageBorderColor = PersonPhotoBorderColor;
        imageWidget.smallImageBorderWidth = PersonPhotoBorderWidth;
        [self.contentView insertSubview:imageWidget aboveSubview:cellLine];
    } else {
        imageWidget.largeImage = mainImage;
        imageWidget.smallImage = relation.person.thumbnailImage;
    }
    CGRect imageRect = CGRectMakeFrameForDeadCenterInRect(self.contentView.frame, CGSizeMake(200, 200));
    imageWidget.frame = CGRectOffset(imageRect, -50, 0);
}

-(void)addLine {
    cellLine = [[FigureTimelineTopCellLine alloc] initWithFrame:self.contentView.bounds numberOfItems:[relation.event.figure.events count]];
    [self.contentView addSubview:cellLine];
}

-(void)fetchFigureProfilePic {
    
    [[ImageDownloadUtil sharedInstance] fetchAndSaveImageForFigure:relation.event.figure completion:^(UIImage *theImage) {
        mainImage = theImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLine];
            [self drawMainCircleImage];
            [self drawBackgroundBlurImage];
        });
    }];
}

@end
