#import "AtYourAgeRequest.h"

@interface AtYourAgeConnection : NSObject <NSURLConnectionDataDelegate>

@property (copy) void (^AYAConnectionCallback)(AtYourAgeRequest *request, id result, NSError *error);

-(id)initWithAtYourAgeRequest:(AtYourAgeRequest *)theRequest;

-(void)getWithCompletionBlock:(void(^)(AtYourAgeRequest *request, id result, NSError *error))_block;

@end
