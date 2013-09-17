#import "ImageWidgetContainer.h"
#import "Utility_AppSettings.h"
#import "ProgressIndicator.h"
#import "Event.h"
#import "Figure.h"
#import "ImageWidget.h"
#import "Person.h"
#import "ObjectArchiveAccessor.h"
#import "ImageDownloadUtil.h"

@implementation ImageWidgetContainer {
        
    IBOutlet UIImageView *personThumbnail;
    IBOutlet UILabel *birthdayLabel;
    IBOutlet UILabel *firstNameLabel;
    IBOutlet UILabel *lastNameLabel;
    IBOutlet UIView *eventView;
    
    UIImage *imageForThumb;
    ProgressIndicator *progressIndicator;
    NSOperationQueue *operationQueue;
    ObjectArchiveAccessor *accessor;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        accessor = [[ObjectArchiveAccessor alloc] init];
        [[NSBundle mainBundle] loadNibNamed:@"ImageWidgetContainer" owner:self options:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePersonThumbnail:) name:KeyForPersonThumbnailUpdated object:nil];
//        [self addObserver:self forKeyPath:@"self.person.thumbnail" options:NSKeyValueObservingOptionNew context:nil];
        _widget = [[ImageWidget alloc] init];
//        self.backgroundColor = [UIColor greenColor];
        [self addSubview:_widget];
        progressIndicator = [[ProgressIndicator alloc] initWithCenterPoint:_widget.center radius:_widget.largeImageRadius - ImageLayerDefaultStrokeWidth];
        [_widget.layer addSublayer:progressIndicator];
    }
    
    return self;
}

-(void)updatePersonThumbnail:(NSNotification *)notif {
    
    id object = notif.userInfo[@"person"];
    if ([object isKindOfClass:[Person class]]) {
        Person *thePerson = (Person *)object;
        
        if ([thePerson.facebookId isEqualToString:_person.facebookId]) {
            _widget.smallImage = [UIImage imageWithData:thePerson.thumbnail];
        }
    }
}

-(void)layoutSubviews {
    
    
    
    if (self.event == nil) {
        
    } else {
            personThumbnail.image = imageForThumb;
            _widget.largeImage = personThumbnail.image;
    }
}

-(void)getFigureThumbnailImage {
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressIndicator animate];
    });
    [[ImageDownloadUtil sharedInstance] fetchAndSaveImageForFigure:self.event.figure completion:^(UIImage *theImage) {
        [progressIndicator stopAnimating];
        imageForThumb = theImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsLayout];
        });
    }];
}

-(void)setEvent:(Event *)event {
    _event = event;
    
    if (_event == nil) {
    } else {
        [self getFigureThumbnailImage];
        [self setNeedsLayout];
    }
}


-(void)setPerson:(Person *)person {
    
    _person = person;
    if (person != nil) {
        UIImage *thumbnail = [UIImage imageWithData:person.thumbnail];
        _widget.smallImage = thumbnail;
    } else {
        _widget.smallImage = nil;
    }
    [self setNeedsLayout];
    
}

-(void)expandWidget {
    _widget.expanded = YES;
}

-(void)collapseWidget {
    _widget.expanded = NO;
}


@end
