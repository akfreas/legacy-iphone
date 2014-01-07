#import "Event.h"
#import "AFNetworking.h"
#import "LegacyAppConnection.h"
@implementation LegacyAppConnection {
    
    LegacyAppRequest *request;
    NSMutableData *resultData;
    id result;
    dispatch_queue_t ourQueue;
}

@synthesize AYAConnectionCallback = _AYAConnectionCallback;

-(id)initWithLegacyRequest:(LegacyAppRequest *)theRequest  {
    self = [super init];
    
    if (self) {
        request = theRequest;
        
        ourQueue = dispatch_queue_create("com.legacyapp.networkqueue", DISPATCH_QUEUE_SERIAL);
        
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
    operation.completionQueue = ourQueue;
    [operation start];
}

-(void)get:(LegacyAppRequest *)aRequest withCompletionBlock:(void (^)(LegacyAppRequest *, id, NSError *))_block {
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:aRequest.urlRequest];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        _block(aRequest, JSON, NULL);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL: %@ Error: %@", operation.request.URL, error);
    }];
    operation.completionQueue = ourQueue;
    [operation start];
}

-(void)postWithCompletionBlock:(void(^)(LegacyAppRequest *request, id result, NSError *error))_block {
    
//    AFHTTPRequestOperation *operation = [AFHTTPRequestOperation set]
    
}

@end
