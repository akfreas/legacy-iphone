#import "YardstickRequest.h"
#import "Event.h"
#import "Person.h"
#import "ObjectArchiveAccessor.h"
#import "Utility_AppSettings.h"

@implementation YardstickRequest {
    
}

@synthesize urlRequest;
@synthesize classToParse;

+(NSURL *)baseUrl {
    
#ifdef DEBUG
    NSString *path = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DebugResourceUrl"];
#else
    NSString *path = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ResourceUrl"];
#endif
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

+(YardstickRequest *)requestToGetEventForPerson:(Person *)person {

    YardstickRequest *request = [self baseRequestForPerson:person];
    NSURL *url = [self eventsUrlForBirthday:person.birthday Person:person.facebookId];
    request.urlRequest.URL = url;
    request.classToParse = [Event class];
    return request;
}

+(YardstickRequest *)requestToGetStoryForPerson:(Person *)person {
    
    YardstickRequest *request = [self baseRequestForPerson:person];
    NSURL *url = [YardstickRequest storyUrlForBirthday:person.birthday Person:person.facebookId];
    request.urlRequest.URL = url;
    request.classToParse = nil;
    
    return request;
}

+(YardstickRequest *)baseRequestForPerson:(Person *)person {
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    NSURL *url = [YardstickRequest storyUrlForBirthday:person.birthday Person:person.facebookId];
    
    Person *primaryPerson = [[ObjectArchiveAccessor sharedInstance] primaryPerson];
    
    NSString *token = FBSession.activeSession.accessToken;
    NSString *activeFbUserId = primaryPerson.facebookId;
    
    NSDictionary *cookieDict = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token", activeFbUserId, @"activeUserId", nil];
    NSData *cookieInfo = [NSJSONSerialization dataWithJSONObject:cookieDict options:NSJSONReadingMutableLeaves error:NULL];
    NSMutableString *cookieInfoString = [[NSMutableString alloc] initWithData:cookieInfo encoding:NSUTF8StringEncoding];
    [cookieInfoString replaceOccurrencesOfString:@"\"" withString:@"'" options:NSLiteralSearch range:NSMakeRange(0, [cookieInfoString length])];
    
    NSDictionary *cookieProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[[self baseUrl] host], NSHTTPCookieDomain, @"/",  NSHTTPCookiePath, cookieInfoString, NSHTTPCookieValue, @"Yardstick", NSHTTPCookieName, nil];
    NSLog(@"Cookie properties: %@", cookieProperties);
    
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObject:cookie]];
    NSLog(@"URL: %@", url);
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
