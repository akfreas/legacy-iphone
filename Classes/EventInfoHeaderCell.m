#import "EventInfoHeaderCell.h"
#import "CircleImageView.h"
#import "Event.h"
#import "Figure.h"

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
        mainImageView = [[CircleImageView alloc] initWithImage:mainImage radius:100];
        [self addSubview:mainImageView];

    } else {
        mainImageView.image = mainImage;
    }
    
    mainImageView.frame = CGRectMakeFrameForDeadCenterInRect(self.frame, mainImageView.frame.size);
}

-(void)fetchFigureProfilePic {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:event.figure.imageURL]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error == nil) {
            mainImage = [UIImage imageWithData:data];
            
            if (mainImage != nil) {
                [self drawMainCircleImage];
            }
        }
    }];
}

@end
