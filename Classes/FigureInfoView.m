#import "FigureInfoView.h"
#import "Utility_AppSettings.h"
#import "Event.h"
#import "ImageWidget.h"

@implementation FigureInfoView {
        
    IBOutlet UIImageView *personThumbnail;
    IBOutlet UILabel *birthdayLabel;
    IBOutlet UILabel *firstNameLabel;
    IBOutlet UILabel *lastNameLabel;
    IBOutlet UIView *eventView;
    
    UIImage *imageForThumb;
    UIActivityIndicatorView *indicatorView;
    NSOperationQueue *operationQueue;
    
    ImageWidget *widget;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        [[NSBundle mainBundle] loadNibNamed:@"FigureInfoView" owner:self options:nil];
//        imageForThumb = [UIImage imageNamed:@"icon.png"];
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return self;
}

-(void)layoutSubviews {
    
    if (self.event.figureName != nil) {

    firstNameLabel.text = self.event.figureName;
    
    lastNameLabel.transform = CGAffineTransformMakeRotation(M_PI/-2);
    }
//    personThumbnail.backgroundColor = [UIColor redColor];
    if (self.event == nil) {
        [personThumbnail addSubview:indicatorView];
        [indicatorView startAnimating];
    } else {
        
        if (imageForThumb == nil) {
            personThumbnail.image = [UIImage imageNamed:@"question.png"];
        } else {
            personThumbnail.image = imageForThumb;
        }
        
        [indicatorView removeFromSuperview];
        widget = [[ImageWidget alloc] initWithSmallImage:imageForThumb largeImage:imageForThumb];
//        widget.angle = 135;
        
        [self addSubview:widget];
    }
    
    
//    [self addSubview:eventView];

}

-(void)getThumbnailImage {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.event.figureProfilePicUrl];
    NSLog(@"Profile pic url: %@", self.event.figureProfilePicUrl);
    [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {
        NSLog(@"Response: %@", (NSHTTPURLResponse *)resp);
        imageForThumb = [UIImage imageWithData:data ];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutSubviews];
        });
    }];
}

-(void)animate {
    
        widget.angle = widget.angle +  10;
}

-(void)setEvent:(Event *)event {
    _event = event;
    if (_event == nil) {
        [indicatorView startAnimating];
    } else {
        [indicatorView stopAnimating];
        [self getThumbnailImage];
        [self layoutSubviews];
    }
}




@end
