#import "EventInfoVIew.h"
#import "Utility_AppSettings.h"
#import "Event.h"

@implementation EventInfoView {
        
    IBOutlet UIImageView *personThumbnail;
    IBOutlet UILabel *birthdayLabel;
    IBOutlet UILabel *firstNameLabel;
    IBOutlet UILabel *lastNameLabel;
    IBOutlet UIView *eventView;
    
    UIImage *imageForThumb;
    UIActivityIndicatorView *indicatorView;
    NSOperationQueue *operationQueue;
}


-(id)initWithEvent:(Event *)anEvent {
    self = [super initWithFrame:CGRectMake(10, 10, 207, 215)];
    
    if (self) {
        self.event = anEvent;
        operationQueue = [[NSOperationQueue alloc] init];
        [[NSBundle mainBundle] loadNibNamed:@"EventInfoView" owner:self options:nil];
//        imageForThumb = [UIImage imageNamed:@"icon.png"];
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return self;
}

-(void)layoutSubviews {
    
    if (self.event.figureName != nil) {
    NSMutableArray *splitStrings = [NSMutableArray arrayWithArray:[self.event.figureName componentsSeparatedByString:@" "]];
    NSString *firstNameString = [splitStrings objectAtIndex:0];
    [splitStrings removeObjectAtIndex:0];
    NSString *remainder = [splitStrings componentsJoinedByString:@" "];
    firstNameLabel.text = firstNameString;
    lastNameLabel.text = remainder;
    
    lastNameLabel.transform = CGAffineTransformMakeRotation(M_PI/-2);
    }
//    personThumbnail.backgroundColor = [UIColor redColor];
    if (self.event == nil) {
        indicatorView.center = CGPointMake(CGRectGetWidth(personThumbnail.frame) /2, CGRectGetHeight(personThumbnail.frame) / 2);
        [personThumbnail addSubview:indicatorView];
        [indicatorView startAnimating];
    } else {
        
        if (imageForThumb == nil) {
            personThumbnail.image = [UIImage imageNamed:@"fb_blank_profile_square.png"];
        } else {
            personThumbnail.image = imageForThumb;
        }
        
        [indicatorView removeFromSuperview];
    }
    [self addSubview:eventView];
}

-(void)getThumbnailImage {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.event.figureProfilePicUrl];
    NSLog(@"Profile pic url: %@", self.event.figureProfilePicUrl);
    [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {
        NSLog(@"Respsonse: %@", (NSHTTPURLResponse *)resp);
        imageForThumb = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutSubviews];
        });
    }];
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
