#import "Event.h"
#import "AFNetworking.h"
#import "AtYourAgeConnection.h"
@implementation AtYourAgeConnection {
    
    AtYourAgeRequest *request;
    NSMutableData *resultData;
    id result;
}

@synthesize AYAConnectionCallback = _AYAConnectionCallback;

-(id)initWithAtYourAgeRequest:(AtYourAgeRequest *)theRequest  {
    self = [super init];
    
    if (self) {
        request = theRequest;
    }
    return self;
}

-(void)getWithCompletionBlock:(void(^)(AtYourAgeRequest *request, id result, NSError *error))_block {
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request.urlRequest success:^(NSURLRequest *URLRequest, NSHTTPURLResponse *response, id JSON) {
        _block(request, JSON, NULL);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Json: %@ Error: %@ response:%@", JSON, error, response);
    }];
    [operation start];
}

@end
