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
    
    NSOperationQueue *operationQueue;
    ObjectArchiveAccessor *accessor;
}


-(id)init {
    self = [super init];
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        accessor = [ObjectArchiveAccessor sharedInstance];
        [self addImageWidget];
    }
    return self;
}

-(void)addImageWidget {
    _widget = [[ImageWidget alloc] init];
    _widget.largeImageRadius = FigurePhotoRadius;
    [self addSubview:_widget];
    UIBind(_widget);
    [self addConstraintWithVisualFormat:@"H:|[_widget]|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:|[_widget]|" bindings:BBindings];

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

-(void)getFigureThumbnailImage {
    [[ImageDownloadUtil sharedInstance] fetchAndSaveImageForFigure:self.event.figure completion:^(UIImage *theImage) {
        if (theImage != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _widget.largeImage = theImage;
            });
        }
    }];
}

-(void)setEvent:(Event *)event {
    _event = event;
    _widget.largeImage = [UIImage imageNamed:@"no-photo.png"];
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
