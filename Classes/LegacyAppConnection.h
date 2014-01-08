#import "LegacyAppRequest.h"

@interface LegacyAppConnection : NSObject <NSURLConnectionDataDelegate>

@property (copy) void (^AYAConnectionCallback)(LegacyAppRequest *request, id result, NSError *error);

-(id)initWithLegacyRequest:(LegacyAppRequest *)theRequest;

-(void)getWithCompletionBlock:(void(^)(LegacyAppRequest *request, id result, NSError *error))_block;
+(void)get:(LegacyAppRequest *)aRequest withCompletionBlock:(void(^)(LegacyAppRequest *request, id result, NSError *error))_block;

@end
