#import "AtYourAgeConnection.h"
#import "Event.h"

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
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request.urlRequest delegate:self startImmediately:NO];
    self.AYAConnectionCallback = _block;
    
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [connection start];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (httpResponse.statusCode != 200) {
            
            NSError *error = [NSError errorWithDomain:@"Status Code Error" 
                                                 code:httpResponse.statusCode
                                             userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Status code %d", httpResponse.statusCode]
                                                                                  forKey:NSLocalizedDescriptionKey]];
            self.AYAConnectionCallback(nil, nil, error);
        }
        resultData = [[NSMutableData alloc] initWithLength:0];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [resultData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    result = nil;
    id parseResult = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:NULL];
    if (request.classToParse != nil && request.classToParse != NULL) {
        
        result = [[request.classToParse alloc] initWithJsonDictionary:parseResult];
    } else { //TODO this should parse up collections of objects
        result = parseResult;
    }
    
    self.AYAConnectionCallback(request, result, nil);
}

@end
