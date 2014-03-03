#import "Event.h"
#import "AFNetworking.h"
#import "LegacyAppConnection.h"
@implementation LegacyAppConnection {
    
    LegacyAppRequest *request;
    NSMutableData *resultData;
    dispatch_queue_t queue;
    id result;
}
static dispatch_queue_t queue;
@synthesize AYAConnectionCallback = _AYAConnectionCallback;

-(id)initWithLegacyRequest:(LegacyAppRequest *)theRequest  {
    self = [super init];
    
    if (self) {
        request = theRequest;
    }
    return self;
}

-(void)getWithCompletionBlock:(void(^)(LegacyAppRequest *request, id result, NSError *error))_block {
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request.urlRequest];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        _block(request, JSON, NULL);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL: %@ Error: %@", operation.request.URL, error);
    }];
    
    [operation start];
}


+(void)get:(LegacyAppRequest *)aRequest withCompletionBlock:(void(^)(LegacyAppRequest *request, id result, NSError *error))_block {
    if (queue == nil) {
        queue = dispatch_queue_create("com.legacyapp.networkqueue", DISPATCH_QUEUE_SERIAL);
    }
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:aRequest.urlRequest];
    operation.completionQueue = queue;
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
#if DEBUG==1
        NSLog(@"Making request:\n \
              URL: %@\n\
              Headers: %@\n\
              Response JSON: %@\n\
//              ", aRequest.urlRequest.URL, [aRequest.urlRequest allHTTPHeaderFields], JSON);
#endif
        _block(aRequest, JSON, NULL);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL: %@ Error: %@", operation.request.URL, error);
    }];
    

    [operation start];
}

-(void)postWithCompletionBlock:(void(^)(LegacyAppRequest *request, id result, NSError *error))_block {
    
//    AFHTTPRequestOperation *operation = [AFHTTPRequestOperation set]
    
}

@end
