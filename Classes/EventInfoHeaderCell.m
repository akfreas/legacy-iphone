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
        [self fetchFigureProfilePic];
    }
    
    return self;
}

#pragma mark Accessors

-(CGPoint)pointForLines {
    
        CGPoint newPoint = CGPointMake(CGRectGetMaxX(mainImagePlaceholder.frame), mainImagePlaceholder.frame.origin.y + mainImagePlaceholder.frame.size.height / 2);
        
        return newPoint;
}

#pragma mark View Helper Methods

-(void)drawMainCircleImage {
    
    if (mainImageView == nil) {
        mainImageView = [[CircleImageView alloc] initWithImage:mainImage radius:mainImagePlaceholder.frame.size.height/2];
        [self insertSubview:mainImageView belowSubview:mainImagePlaceholder];
//        figureNameLabel.frame = CGRectMakeFrameForCenter(mainImageView, figureNameLabel.frame.size, mainImageView.frame.size.height - 50);
//        figureNameLabel.layer.cornerRadius = 10;
//        figureNameLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
//        [mainImageView addSubview:figureNameLabel];

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
