#import "FigureTimelineTopCell.h"
#import "ImageWidget.h"
#import "Event.h"
#import "Figure.h"
#import "Person.h"
#import "ImageDownloadUtil.h"
#import "EventPersonRelation.h"
#import "FigureTimelineTopCellLine.h"

#import <CoreImage/CoreImage.h>
#define BackgroundFadeInAnimationDuration 0.5f

@interface FigureTimelineTopCell ()

@property (nonatomic, retain) dispatch_queue_t imageProcessingQueue;
@property (nonatomic, retain)  NSMutableArray *layoutConstraintsForBackgroundImageView;
@property (nonatomic, retain) UIImageView *currentBackground;
@end

@implementation FigureTimelineTopCell {
    
    ImageWidget *imageWidget;
    FigureTimelineTopCellLine *cellLine;
    UILabel *personNameLabel;
}

static UIImage *DefaultBlurImage;


-(id)init {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifierForHeader];
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.imageProcessingQueue = dispatch_queue_create("com.sashimiblade.legacyapp.imageprocessing", DISPATCH_QUEUE_SERIAL);
        self.contentView.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    
    return self;
}
-(void)addBackgroundViewForImage:(UIImage *)backgroundImage {
    
    if (self.currentBackground == nil) {
        self.currentBackground = [[UIImageView alloc] initWithImage:backgroundImage];
        [self.contentView insertSubview:self.currentBackground belowSubview:cellLine];
        NSDictionary *BBindings = @{@"imageView": self.currentBackground};
        [self.contentView addConstraintWithVisualFormat:@"H:|[imageView]|" bindings:BBindings];
        [self.contentView addConstraintWithVisualFormat:@"V:|[imageView]|" bindings:BBindings];
    } else {
        self.currentBackground.image = backgroundImage;
    }
    if (backgroundImage != nil) {
        [UIView animateWithDuration:BackgroundFadeInAnimationDuration animations:^{
            self.currentBackground.alpha = 1;
        }];
    }
}

-(void)drawBackgroundBlurImageWithImage:(UIImage *)ourImage completion:(void(^)(UIImage *blurImage))completion {
    
    dispatch_async(self.imageProcessingQueue, ^{
        
        CGFloat transform = self.contentView.frame.size.width / ourImage.size.width;
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *image = [CIImage imageWithCGImage:ourImage.CGImage];
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
        UIImage *blurImage = [UIImage imageWithCGImage:imgRef];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(blurImage);
        });
    });

}

#pragma mark Accessors

-(void)setRelation:(EventPersonRelation *)relation {
    if (relation != _relation) {
        _relation = relation;
        imageWidget.largeImage = _relation.event.figure.imageData != nil ? _relation.event.figure.image :NoProfilePhotoImage;
        imageWidget.smallImage = _relation.person.thumbnailImage;
        self.currentBackground.alpha = 0;
        personNameLabel.text = @"";
        [self fetchFigureProfilePic];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self addAndConfigureLine];
    [self drawMainCircleImage];
    if (self.relation.event.figure.imageData == nil) {
        if (DefaultBlurImage == nil) {
            [self drawBackgroundBlurImageWithImage:NoProfilePhotoImage completion:^(UIImage *blurImage) {
                DefaultBlurImage = blurImage;
                [self addBackgroundViewForImage:DefaultBlurImage];
            }];
        } else {
            [self addBackgroundViewForImage:DefaultBlurImage];
        }
    }
    if (personNameLabel != nil) {
        CGFloat labelWidth = 120;
        CGFloat labelHeight = 30;
        CGFloat rightMargin = 20;
        CGRect rect = CGRectMake(CGRectGetMaxX(self.contentView.frame) - labelWidth - rightMargin, CGRectGetMaxY(self.contentView.frame) - 70, labelWidth, labelHeight);
        personNameLabel.frame = rect;
    }
}

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
        imageWidget = [[ImageWidget alloc] initWithSmallImage:nil largeImage:NoProfilePhotoImage];
        imageWidget.largeImageRadius = 60;
        imageWidget.smallImageRadius = 30;
        imageWidget.largeImageBorderWidth = PersonPhotoBorderWidth;
        imageWidget.largeImageBorderColor = PersonPhotoBorderColor;
        imageWidget.smallImageBorderColor = PersonPhotoBorderColor;
        imageWidget.smallImageBorderWidth = PersonPhotoBorderWidth;
        [self.contentView insertSubview:imageWidget aboveSubview:cellLine];
        
        CGRect imageRect = CGRectMakeFrameForDeadCenterInRect(self.contentView.frame, CGSizeMake(200, 200));
        imageWidget.frame = CGRectOffset(imageRect, -65, 0);
    }
}
-(void)fillCircleImages {
    if (_relation.event.figure.image != nil) {
        imageWidget.largeImage = _relation.event.figure.image;
    }
    if (_relation.person.thumbnailImage != nil) {
        imageWidget.smallImage = _relation.person.thumbnailImage;
    }
}

-(void)addAndConfigureLine {
    if (cellLine == nil) {
        cellLine = [[FigureTimelineTopCellLine alloc] initWithFrame:self.contentView.bounds numberOfItems:[_relation.event.figure.events count]];
        [self.contentView addSubview:cellLine];
    } else {
        cellLine.numberOfItems = [_relation.event.figure.events count]; 
    }
}

-(void)addPersonNameLabel {
    if (personNameLabel == nil) {
        personNameLabel = [[UILabel alloc] initForAutoLayout];
        [self.contentView addSubview:personNameLabel];
        personNameLabel.font = PersonNameTopCellFont;
        personNameLabel.textColor = PersonNameTopCellColor;
        personNameLabel.contentMode = UIViewContentModeScaleAspectFit;
        [self setNeedsLayout];
    }
    personNameLabel.text = _relation.person.fullName;
}

-(void)fetchFigureProfilePic {
    
    [[ImageDownloadUtil sharedInstance] fetchAndSaveImageForFigure:_relation.event.figure completion:^(UIImage *theImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fillCircleImages];
            if (_relation.event.figure.image != nil) {
                [self drawBackgroundBlurImageWithImage:_relation.event.figure.image completion:^(UIImage *blurImage) {
                    [self addBackgroundViewForImage:blurImage];
                }];
            }
            if (_relation.person != nil) {
                [self addPersonNameLabel];
            }
        });
    }];
}

@end
