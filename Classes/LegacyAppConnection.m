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
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request.urlRequest success:^(NSURLRequest *URLRequest, NSHTTPURLResponse *response, id JSON) {
        
        _block(request, JSON, NULL);
    } failure:^(NSURLRequest *theRequest, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"URL: %@ Response: %@ Error: %@ JSON:%@", theRequest.URL, response, error, JSON);
    }];
    [operation start];
}

-(void)postWithCompletionBlock:(void(^)(LegacyAppRequest *request, id result, NSError *error))_block {
    
//    AFHTTPRequestOperation *operation = [AFHTTPRequestOperation set]
    
}

@end
