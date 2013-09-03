#import "EventInfoHeaderCell.h"
#import "CircleImageView.h"
#import "Event.h"
#import "Figure.h"
#import "ImageDownloadUtil.h"
#import "FigureNameLabelBlurLayer.h"

#import <CoreImage/CoreImage.h>

@interface EventInfoHeaderCell ()

@property (strong, nonatomic, readwrite) NSString *reuseIdentifier;

@end

@implementation EventInfoHeaderCell {
    
    Event *event;
    CircleImageView *mainImageView;
    CircleImageView *personImageView;
    FigureNameLabelBlurLayer *blurLayer;
    
    UIImage *mainImage;
    UIImageView *labelImageView;
    CGRect figureNameLabelInitialFrame;

    IBOutlet UIView *mainImagePlaceholder;
}

-(id)initWithEvent:(Event *)anEvent {
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
    
    if (self) {
        event = anEvent;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.reuseIdentifier = TableViewCellIdentifierForHeader;
        blurLayer = [[FigureNameLabelBlurLayer alloc] initWithString:event.figure.name];
        blurLayer.frame = CGRectMakeFrameForDeadCenterInRect(self.frame, CGSizeMake(self.frame.size.width, 55));
        figureNameLabelInitialFrame = blurLayer.frame;
        [self fetchFigureProfilePic];
    }
    
    return self;
}

#pragma mark Accessors


-(void)setNameLabelOriginYOffset:(CGFloat)offset {
    
    blurLayer.frame = CGRectSetOriginOnRect(blurLayer.frame, figureNameLabelInitialFrame.origin.x, figureNameLabelInitialFrame.origin.y + offset);
    blurLayer.blurFactor = offset;
}

-(CGPoint)pointForLines {
    
        CGPoint newPoint = CGPointMake(CGRectGetMaxX(mainImagePlaceholder.frame), mainImagePlaceholder.frame.origin.y + mainImagePlaceholder.frame.size.height / 2);
        
        return newPoint;
}

#pragma mark View Helper Methods

-(void)drawFigureNameLabel {

    [self insertSubview:blurLayer atIndex:1];

}

-(void)drawMainCircleImage {
    
    if (mainImageView == nil) {
        mainImageView = [[CircleImageView alloc] initWithImage:mainImage radius:mainImagePlaceholder.frame.size.height/2];

        [self insertSubview:mainImageView atIndex:2];
        [self drawFigureNameLabel];
    } else {
        mainImageView.image = mainImage;
    }
    mainImageView.frame = CGRectMake(mainImagePlaceholder.frame.origin.x, mainImagePlaceholder.frame.origin.y, mainImageView.frame.size.width, mainImageView.frame.size.height);
//    [mainImagePlaceholder removeFromSuperview];
}

-(void)fetchFigureProfilePic {
    
    [[ImageDownloadUtil sharedInstance] fetchAndSaveImageForFigure:event.figure completion:^(UIImage *theImage) {
        mainImage = theImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawMainCircleImage];
        });
    }];
}

@end
