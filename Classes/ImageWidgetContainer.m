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
        accessor = [ObjectArchiveAccessor sharedInstance];
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
        _widget = [[ImageWidget alloc] init];
//        self.backgroundColor = [UIColor greenColor];
        [self addSubview:_widget];
        progressIndicator = [[ProgressIndicator alloc] initWithCenterPoint:_widget.center radius:_widget.largeImageRadius - ImageLayerDefaultStrokeWidth];
        [_widget.layer addSublayer:progressIndicator];
    }
    
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id newObject = change[NSKeyValueChangeNewKey];
    if (newObject != nil && [newObject isKindOfClass:[NSData class]]) {
        _widget.smallImage = [UIImage imageWithData:newObject];
    }
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
    
    imageForThumb = nil;
    personThumbnail.image = nil;
    _widget.largeImage = nil;
    progressIndicator.hidden = YES;
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
        [self addObserver:self forKeyPath:@"self.person.thumbnail" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        _widget.smallImage = nil;
    }
    [self setNeedsLayout];
    
}

-(void)dealloc {
    
    if (_person != nil) {
        [self removeObserver:self forKeyPath:@"self.person.thumbnail"];
    }
}

-(void)expandWidget {
    _widget.expanded = YES;
}

-(void)collapseWidget {
    _widget.expanded = NO;
}


@end
