#import "AtYourAgeRequest.h"
#import "Event.h"

@implementation AtYourAgeRequest {
    NSURLRequest *request;
    Class requestClass;
}

+(NSURL *)baseUrl {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AtYourAge-Info" ofType:@"plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSURL *url = [NSURL URLWithString:[plistDict objectForKey:@"ResourceUrl"]];
    return url;
}

+(NSURL *)appendToBaseUrl:(NSString *)theUrl {
    
    NSURL *url = [[AtYourAgeRequest baseUrl] URLByAppendingPathComponent:theUrl];
    return url;
}

+(AtYourAgeRequest *)requestToGetEventWithBirthday:(NSDate *)birthday {

    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    NSURL *url = [AtYourAgeRequest appendToBaseUrl:@"/events"];
    [urlRequest setURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AtYourAgeRequest *request = [[AtYourAgeRequest alloc] initWithRequest:urlRequest classToParse:[Event class]];
    
    return request;
}

-(id)initWithRequest:(NSURLRequest *)theRequest {
    self = [super init];
    
    if (self) {
        request = theRequest;
    }
    
    return self;
}

-(id)initWithRequest:(NSURLRequest *)theRequest classToParse:(Class)theClass {
    self = [self initWithRequest:theRequest];
    
    if (self) {
        requestClass = theClass;
    }
    
    return self;
}

@end