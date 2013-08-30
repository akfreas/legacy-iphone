#import "ImageDownloadUtil.h"
#import "ObjectArchiveAccessor.h"
#import "Figure.h"

@implementation ImageDownloadUtil {
    
    NSOperationQueue *operationQueue;
}

+(ImageDownloadUtil *)sharedInstance {
    static ImageDownloadUtil *instance;
    
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[ImageDownloadUtil alloc] init];
        });
    }
    return instance;
}

-(id)init {
    self = [super init];
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)fetchAndSaveImageForFigure:(Figure *)figure completion:(void(^)(UIImage *))completion {
    NSManagedObjectID *figureId = [figure objectID];
    NSLog(@"ImageData: %@", figure.imageData);
    if (figure.imageData == nil) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:figure.imageURL]];
        [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            ObjectArchiveAccessor *accessor = [[ObjectArchiveAccessor alloc] init];
            Figure *ourFigure = (Figure *)[accessor.managedObjectContext objectWithID:figureId];
            ourFigure.imageData = data;
            [accessor save];
            UIImage *theImage = [UIImage imageWithData:data];
            completion(theImage);
        }];
    } else {
        completion(figure.image);
    }
}

@end
