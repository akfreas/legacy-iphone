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
@implementation FigureTimelineTopCell {
    
    ImageWidget *imageWidget;
    FigureTimelineTopCellLine *cellLine;
    UIImage *figureProfileImage;
    UIImageView *blurBackgroundImageView;
    UILabel *personNameLabel;
    NSMutableArray *layoutConstraintsForBackgroundImageView;
    NSOperationQueue *queue;
}

static UIImage *DefaultBlurImage;


-(id)init {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifierForHeader];
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        queue = [[NSOperationQueue alloc] init];
        self.contentView.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    
    return self;
}
-(void)addBackgroundViewForImage:(UIImage *)backgroundImage {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
    imageView.alpha = 0;
    __weak FigureTimelineTopCell *instance = self;

    if (blurBackgroundImageView != nil && [backgroundImage isEqual:blurBackgroundImageView.image] == NO) {
        [UIView animateWithDuration:BackgroundFadeInAnimationDuration animations:^{
            blurBackgroundImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [blurBackgroundImageView removeFromSuperview];
            [instance addBackgroundImageView:imageView completion:^{
                blurBackgroundImageView = imageView;
            }];
        }];
    } else {
        [instance addBackgroundImageView:imageView completion:^{
            blurBackgroundImageView = imageView;
        }];
    }
}

-(void)addBackgroundImageView:(UIImageView *)imageView completion:(void(^)())completion {
    [self.contentView insertSubview:imageView belowSubview:cellLine];
    if (layoutConstraintsForBackgroundImageView == nil) {
        layoutConstraintsForBackgroundImageView = [NSMutableArray array];
        UIBind(imageView);
        [layoutConstraintsForBackgroundImageView addObjectsFromArray:[self.contentView addConstraintWithVisualFormat:@"H:|[imageView]|" bindings:BBindings]];
        [layoutConstraintsForBackgroundImageView addObjectsFromArray:[self.contentView addConstraintWithVisualFormat:@"V:|[imageView]|" bindings:BBindings]];
    }
    imageView.alpha = 0;
    [UIView animateWithDuration:BackgroundFadeInAnimationDuration animations:^{
        imageView.alpha = 1;
    }completion:^(BOOL finished) {
        if (completion != NULL) {
            completion();
        }
    }];
}

-(void)drawBackgroundBlurImageWithImage:(UIImage *)ourImage completion:(void(^)(UIImage *blurImage))completion {
    
    [queue addOperationWithBlock:^{
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
    }];

}

#pragma mark Accessors

-(void)setRelation:(EventPersonRelation *)relation {
    if (relation != _relation) {
        _relation = relation;
        imageWidget.largeImage = NoProfilePhotoImage;
        imageWidget.smallImage = nil;
        personNameLabel.text = @"";
        [blurBackgroundImageView removeFromSuperview];
        blurBackgroundImageView = nil;
        figureProfileImage = nil;
        [self fetchFigureProfilePic];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self addAndConfigureLine];
    [self drawMainCircleImage];
    if (figureProfileImage == nil) {
        if (DefaultBlurImage == nil && [queue operationCount] == 0) {
            [self drawBackgroundBlurImageWithImage:NoProfilePhotoImage completion:^(UIImage *blurImage) {
                DefaultBlurImage = blurImage;
                [self addBackgroundViewForImage:DefaultBlurImage];
            }];
        } else if (blurBackgroundImageView == nil && [queue operationCount] == 0) {
            [self addBackgroundViewForImage:DefaultBlurImage];
        }
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
    if (figureProfileImage != nil) {
        imageWidget.largeImage = figureProfileImage;
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
        CGRect rect = CGRectMakeFrameWithOriginInBottomOfFrame(imageWidget.frame, self.frame.size.width - CGRectGetMaxX(imageWidget.frame), 35);
        personNameLabel.frame = CGRectOffset(rect, 130, -40);
        personNameLabel.font = PersonNameTopCellFont;
        personNameLabel.textColor = PersonNameTopCellColor;
        personNameLabel.contentMode = UIViewContentModeScaleAspectFit;
    }
    personNameLabel.text = _relation.person.fullName;
}

-(void)fetchFigureProfilePic {
    
    [[ImageDownloadUtil sharedInstance] fetchAndSaveImageForFigure:_relation.event.figure completion:^(UIImage *theImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            figureProfileImage = theImage;
            [self fillCircleImages];
            [self drawBackgroundBlurImageWithImage:figureProfileImage completion:^(UIImage *blurImage) {
                [self addBackgroundViewForImage:blurImage];
            }];
            
            if (_relation.person != nil) {
                [self addPersonNameLabel];
            }
        });
    }];
}

@end
