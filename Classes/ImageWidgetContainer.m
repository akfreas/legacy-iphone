#import "ImageWidgetContainer.h"
#import "Utility_AppSettings.h"
#import "Event.h"
#import "Figure.h"
#import "ImageWidget.h"
#import "Person.h"

@implementation ImageWidgetContainer {
        
    IBOutlet UIImageView *personThumbnail;
    IBOutlet UILabel *birthdayLabel;
    IBOutlet UILabel *firstNameLabel;
    IBOutlet UILabel *lastNameLabel;
    IBOutlet UIView *eventView;
    
    UIImage *imageForThumb;
    UIActivityIndicatorView *indicatorView;
    NSOperationQueue *operationQueue;
    
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        [[NSBundle mainBundle] loadNibNamed:@"ImageWidgetContainer" owner:self options:nil];
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        [self addObserver:self forKeyPath:@"self.person.thumbnail" options:NSKeyValueObservingOptionNew context:nil];
        _widget = [[ImageWidget alloc] init];
//        self.backgroundColor = [UIColor greenColor];
        [self addSubview:_widget];
    }
    
    return self;
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"thumbnail data: %@ \n %@", change[@"new"], _person.thumbnail);
//    _widget.smallImage = [UIImage imageWithData:_person.thumbnail];
//}

-(void)layoutSubviews {
    
    
    
    if (self.event == nil) {
//        [personThumbnail addSubview:indicatorView];
//        [indicatorView startAnimating];
    } else {
        
        if (imageForThumb == nil) {
            personThumbnail.image = [UIImage imageNamed:@"question.png"];
        } else {
            personThumbnail.image = imageForThumb;
            _widget.largeImage = personThumbnail.image;
        }
    }
}

-(void)getThumbnailImage {
    
    
    NSURL *imageURL = [NSURL URLWithString:self.event.figure.imageURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:imageURL];
    NSLog(@"Profile pic url: %@", imageURL);
    
    [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {
        NSLog(@"Response: %@", (NSHTTPURLResponse *)resp);
        imageForThumb = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutSubviews];
            [[NSNotificationCenter defaultCenter] postNotificationName:KeyForEventLoadingComplete object:self];
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
        [self setNeedsLayout];
    }
}


-(void)setPerson:(Person *)person {
    
    UIImage *thumbnail = [UIImage imageWithData:person.thumbnail];
    
    _widget.smallImage = thumbnail;
    [self setNeedsLayout];
    
}

-(void)expandWidget {
    _widget.expanded = YES;
}

-(void)collapseWidget {
    _widget.expanded = NO;
}


@end
