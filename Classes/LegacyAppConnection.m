#import "Event.h"
#import "AFNetworking.h"
#import "LegacyAppConnection.h"
@implementation LegacyAppConnection {
    
    LegacyAppRequest *request;
    NSMutableData *resultData;
    id result;
}

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

-(void)postWithCompletionBlock:(void(^)(LegacyAppRequest *request, id result, NSError *error))_block {
    
//    AFHTTPRequestOperation *operation = [AFHTTPRequestOperation set]
    
}

@end
