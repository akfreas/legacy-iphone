#import "ImageDownloadUtil.h"
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
            NSManagedObjectContext *ctx = [NSManagedObjectContext MR_contextForCurrentThread];
            Person *ourPerson = [Person objectWithObjectID:personID inContext:ctx];
            ourPerson.thumbnail = UIImagePNGRepresentation(image);
            [ctx MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image);
                });
            }];
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
            if (data != nil) {
                NSManagedObjectContext *ctx = [NSManagedObjectContext MR_contextForCurrentThread];
                Figure *ourFigure = [Figure objectWithObjectID:figureID inContext:ctx];
                [ctx performBlockAndWait:^{
                    ourFigure.imageData = data;
                    [ctx MR_saveOnlySelfAndWait];
                }];
            }
            UIImage *theImage = [UIImage imageWithData:data];
            completion(theImage);
        }];
    } else {
        UIImage *image = [UIImage imageWithData:figure.imageData];
        completion(image);
    }
}

@end
