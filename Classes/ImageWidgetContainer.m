#import "ImageWidgetContainer.h"
#import "Utility_AppSettings.h"
#import "ProgressIndicator.h"
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
    ProgressIndicator *progressIndicator;
    NSOperationQueue *operationQueue;
    
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        [[NSBundle mainBundle] loadNibNamed:@"ImageWidgetContainer" owner:self options:nil];
//        [self addObserver:self forKeyPath:@"self.person.thumbnail" options:NSKeyValueObservingOptionNew context:nil];
        _widget = [[ImageWidget alloc] init];
//        self.backgroundColor = [UIColor greenColor];
        [self addSubview:_widget];
        progressIndicator = [[ProgressIndicator alloc] initWithCenterPoint:_widget.center radius:_widget.largeImageRadius - ImageLayerDefaultStrokeWidth];
        [_widget.layer addSublayer:progressIndicator];
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
        
            personThumbnail.image = imageForThumb;
            _widget.largeImage = personThumbnail.image;
    }
}

-(void)getThumbnailImage {
    
    
    NSURL *imageURL = [NSURL URLWithString:self.event.figure.imageURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:imageURL];
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressIndicator animate];
    });
    [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {
        imageForThumb = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutSubviews];
            [progressIndicator stopAnimating];
        });
    }];
}

-(void)setEvent:(Event *)event {
    _event = event;
    
    if (_event == nil) {
    } else {
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
