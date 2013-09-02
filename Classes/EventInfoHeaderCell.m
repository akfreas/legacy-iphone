#import "EventInfoHeaderCell.h"
#import "CircleImageView.h"
#import "Event.h"
#import "Figure.h"
#import "ImageDownloadUtil.h"

@interface EventInfoHeaderCell ()

@property (strong, nonatomic, readwrite) NSString *reuseIdentifier;

@end

@implementation EventInfoHeaderCell {
    
    Event *event;
    CircleImageView *mainImageView;
    CircleImageView *personImageView;
    
    UIImage *mainImage;
    CGRect figureNameLabelInitialFrame;

    IBOutlet UIView *mainImagePlaceholder;
    IBOutlet UILabel *figureNameLabel;
}

-(id)initWithEvent:(Event *)anEvent {
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
    
    if (self) {
        event = anEvent;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.reuseIdentifier = TableViewCellIdentifierForHeader;
        figureNameLabel.text = event.figure.name;
        figureNameLabelInitialFrame = figureNameLabel.frame;
        [self fetchFigureProfilePic];
    }
    
    return self;
}

#pragma mark Accessors


-(void)setNameLabelOriginYOffset:(CGFloat)offset {
    
    figureNameLabel.frame = CGRectSetOriginOnRect(figureNameLabel.frame, figureNameLabelInitialFrame.origin.x, figureNameLabelInitialFrame.origin.y + offset);
}

-(CGPoint)pointForLines {
    
        CGPoint newPoint = CGPointMake(CGRectGetMaxX(mainImagePlaceholder.frame), mainImagePlaceholder.frame.origin.y + mainImagePlaceholder.frame.size.height / 2);
        
        return newPoint;
}

#pragma mark View Helper Methods

-(void)drawFigureNameLabel {
    CGFloat actualFontSize;
    CGSize nameLabelSize = [figureNameLabel.text sizeWithFont:[UIFont fontWithName:@"Georgia" size:60] minFontSize:12 actualFontSize:&actualFontSize forWidth:self.bounds.size.width - 20 lineBreakMode:NSLineBreakByTruncatingTail];
    figureNameLabel.frame = figureNameLabelInitialFrame = CGRectMake(10, 20, nameLabelSize.width, nameLabelSize.height);
    figureNameLabel.font = [UIFont fontWithName:@"Georgia" size:actualFontSize];
    [self insertSubview:figureNameLabel belowSubview:mainImageView];

}

-(void)drawMainCircleImage {
    
    if (mainImageView == nil) {
        mainImageView = [[CircleImageView alloc] initWithImage:mainImage radius:mainImagePlaceholder.frame.size.height/2];
        [self insertSubview:mainImageView belowSubview:mainImagePlaceholder];
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
