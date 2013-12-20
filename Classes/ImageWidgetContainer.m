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
    
    UIImage *imageForThumb;
    NSOperationQueue *operationQueue;
    ObjectArchiveAccessor *accessor;
}


-(id)init {
    self = [super init];
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        accessor = [ObjectArchiveAccessor sharedInstance];
        _widget = [[ImageWidget alloc] init];
        self.backgroundColor = [UIColor greenColor];
        [self addSubview:_widget];
        UIBind(_widget);
        [self addConstraintWithVisualFormat:@"H:|[_widget]|" bindings:BBindings];
        [self addConstraintWithVisualFormat:@"V:|[_widget]|" bindings:BBindings];
        
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
    [super layoutSubviews];

    if (self.event == nil) {
        
    } else {
        personThumbnail.image = imageForThumb;
        _widget.largeImage = personThumbnail.image;
    }
}

-(void)getFigureThumbnailImage {
    [[ImageDownloadUtil sharedInstance] fetchAndSaveImageForFigure:self.event.figure completion:^(UIImage *theImage) {
        imageForThumb = theImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            _widget.largeImage = theImage;
            [self setNeedsLayout];
        });
    }];
}

-(void)setEvent:(Event *)event {
    _event = event;
    
    imageForThumb = nil;
    personThumbnail.image = nil;
    _widget.largeImage = nil;
    [self getFigureThumbnailImage];
    [self setNeedsLayout];
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

@end
