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
    
    NSOperationQueue *queue;
}

-(id)initWithEvent:(Event *)anEvent {
    self = [super init];
    
    if (self) {
        event = anEvent;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor orangeColor];
        self.reuseIdentifier = @"HeaderTableViewCell";
        queue = [[NSOperationQueue alloc] init];
        [self fetchFigureProfilePic];
    }
    
    return self;
}


#pragma mark View Helper Methods

-(void)drawMainCircleImage {
    
    if (mainImageView == nil) {
        mainImageView = [[CircleImageView alloc] initWithImage:mainImage radius:80];
        [self addSubview:mainImageView];

    } else {
        mainImageView.image = mainImage;
    }
    
    mainImageView.frame = CGRectMakeFrameForDeadCenterInRect(self.frame, mainImageView.frame.size);
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
