#import "ImageWidgetContainer.h"
#import "Utility_AppSettings.h"
#import "ProgressIndicator.h"
#import "Event.h"
#import "Figure.h"
#import "EventPersonRelation.h"
#import "ImageWidget.h"
#import "Person.h"

#import "ImageDownloadUtil.h"

@implementation ImageWidgetContainer {
    
    NSOperationQueue *operationQueue;
}

-(id)initWithRelation:(EventPersonRelation *)relation {
    self = [self init];
    if (self) {
        self.relation = relation;
    }
    return self;
}

-(id)init {
    self = [super init];
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
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
        
        if ([thePerson.facebookId isEqualToString:_relation.person.facebookId]) {
            _widget.smallImage = [UIImage imageWithData:thePerson.thumbnail];
        }
    }
}

-(void)getFigureThumbnailImage {
    if (_relation.event.figure != nil) {
        [[ImageDownloadUtil sharedInstance] fetchAndSaveImageForFigure:_relation.event.figure completion:^(UIImage *theImage) {
            if (theImage != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _widget.largeImage = theImage;
                });
            }
        }];
    }
}

-(void)getPersonThumbnailImage {
    [[ImageDownloadUtil sharedInstance] fetchAndSaveImageForPerson:_relation.person completion:^(UIImage *thumbnail) {
        _widget.smallImage = thumbnail;
        _widget.smallImageOffset = PersonPhotoOffset;
        _widget.smallImageBorderColor = PersonPhotoBorderColor;
        _widget.smallImageBorderWidth = PersonPhotoBorderWidth;
    }];
}

-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    if (relation.event == nil) {
        _widget.largeImage = NoEventImage;
    } else {
        _widget.largeImage = [UIImage imageNamed:@"no-photo.png"];
    }
    [self getFigureThumbnailImage];
    [self setNeedsLayout];
    
    if (_relation.person != nil) {
        [self getPersonThumbnailImage];
    } else {
        _widget.smallImage = nil;
    }
    [self setNeedsLayout];
}

@end
