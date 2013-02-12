#import "YardstickRequest.h"
#import "Event.h"
#import "YardstickPerson.h"

@implementation YardstickRequest {
    
}

@synthesize urlRequest;
@synthesize classToParse;

+(NSURL *)baseUrl {
    
    NSString *path = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ResourceUrl"];
    NSURL *url = [NSURL URLWithString:path];
    return url;
}

+(NSURL *)appendToBaseUrl:(NSString *)theUrl {
    
    NSURL *url = [[YardstickRequest baseUrl] URLByAppendingPathComponent:theUrl];
    return url;
}

+(NSURL *)eventsUrlForBirthday:(NSDate *)theDate Person:(NSString *)user {
    
    NSDateFormatter *formatter = [Utility_AppSettings dateFormatterForRequest];
    
    NSURL *url = [YardstickRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"%@/event/%@", user, [formatter stringFromDate:theDate]];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)storyUrlForBirthday:(NSDate *)theDate Person:(NSString *)user {
    
    NSDateFormatter *formatter = [Utility_AppSettings dateFormatterForRequest];
    
    NSURL *url = [YardstickRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"%@/story/%@", user, [formatter stringFromDate:theDate]];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlToPostUser {
    
    NSURL *url = [YardstickRequest baseUrl];
    NSString *pathString = @"user/";
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(YardstickRequest *)requestToGetEventForPerson:(User *)user {

    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    NSURL *url = [YardstickRequest eventsUrlForBirthday:user.birthday Person:user.facebookId];
    [urlRequest setURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    YardstickRequest *request = [[YardstickRequest alloc] initWithRequest:urlRequest classToParse:[Event class]];
    
    return request;
}

+(YardstickRequest *)requestToGetStoryForPerson:(User *)user {
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    NSURL *url = [YardstickRequest storyUrlForBirthday:user.birthday Person:user.facebookId];

    NSString *token = FBSession.activeSession.accessToken;
    
    NSDictionary *cookieProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[[self baseUrl] host], NSHTTPCookieDomain, @"/",  NSHTTPCookiePath, token, NSHTTPCookieValue, @"Yardstick", NSHTTPCookieName, nil];
    
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObject:cookie]];
    [urlRequest setAllHTTPHeaderFields:headers];
    [urlRequest setURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
    YardstickRequest *request = [[YardstickRequest alloc] initWithRequest:urlRequest classToParse:nil];
    
    return request;
}

+(YardstickRequest *)requestToPostMainUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName birthday:(NSDate *)birthday {
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    
    NSURL *url = [YardstickRequest urlToPostUser];
    
    [urlRequest setURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    
    
    
}

-(id)initWithRequest:(NSURLRequest *)theRequest {
    self = [super init];
    
    if (self) {
        urlRequest = theRequest;
    }
    
    return self;
}

-(id)initWithRequest:(NSURLRequest *)theRequest classToParse:(Class)theClass {
    self = [self initWithRequest:theRequest];
    
    if (self) {
        classToParse = theClass;
    }
    
    return self;
}

@end
