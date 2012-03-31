#import "AtYourAgeConnection.h"
#import "Event.h"
#import "SBJsonParser.h"

@implementation AtYourAgeConnection {
    
    AtYourAgeRequest *request;
    SBJsonParser *parser;
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
    parser = [[SBJsonParser alloc] init];
    
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
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [resultData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    result = nil;
    
    if (request.classToParse != nil && request.classToParse != NULL) {
        
        id parseResult = [parser objectWithData:resultData];
        
        if ([parseResult isKindOfClass:[NSArray class]]) {

            NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
            
            for (NSDictionary *jsonDict in parseResult) {
                [resultArray addObject:[[request.classToParse alloc] initWithJsonDictionary:jsonDict]];
            }
            result = resultArray;
        }
    }
    
    self.AYAConnectionCallback(request, result, nil);
}

@end