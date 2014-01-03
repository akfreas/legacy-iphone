#import "ImageDownloadUtil.h"
#import "PersistenceManager.h"
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

-(void)fetchAndSaveImageForPerson:(Person *)person completion:(void(^)(UIImage *))completion {
    
    NSManagedObjectID *personID = person.objectID;
    if (person.thumbnail == nil) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:person.profilePicURL]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage *image) {
            PersistenceManager *ourManager = [PersistenceManager new];
            Person *ourPerson = [Person objectWithObjectID:personID inContext:ourManager.managedObjectContext];
            ourPerson.thumbnail = UIImagePNGRepresentation(image);
            [ourPerson save];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image);
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image download failed for %@. Error: %@", person, error);
        }];
        [operation start];
    } else {
        UIImage *image = [UIImage imageWithData:person.thumbnail];
        completion(image);
    }

}
-(void)fetchAndSaveImageForFigure:(Figure *)figure completion:(void(^)(UIImage *))completion {
    NSManagedObjectID *figureID = figure.objectID;
    if (figure.imageData == nil) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:figure.imageURL]];
        [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                PersistenceManager *ourManager = [PersistenceManager new];
                Figure *ourFigure = [Figure objectWithObjectID:figureID inContext:ourManager.managedObjectContext];
                ourFigure.imageData = data;
                [ourManager save];
            });
            UIImage *theImage = [UIImage imageWithData:data];
            completion(theImage);
        }];
    } else {
        completion(figure.image);
    }
}

@end
