#import "YardstickRequest.h"

@interface YardstickConnection : NSObject <NSURLConnectionDataDelegate>

@property (copy) void (^AYAConnectionCallback)(YardstickRequest *request, id result, NSError *error);

-(id)initWithYardstickRequest:(YardstickRequest *)theRequest;

-(void)getWithCompletionBlock:(void(^)(YardstickRequest *request, id result, NSError *error))_block;

@end
