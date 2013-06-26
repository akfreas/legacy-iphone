#import "AtYourAgeRequest.h"
#import "Event.h"
#import "Person.h"
#import "Figure.h"
#import "ObjectArchiveAccessor.h"
#import "Utility_AppSettings.h"

@implementation AtYourAgeRequest {
    
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
    
    NSURL *url = [[AtYourAgeRequest baseUrl] URLByAppendingPathComponent:theUrl];
    return url;
}


+(NSURL *)storyUrlForBirthday:(NSDate *)theDate Person:(NSString *)user {
        
    NSURL *url = [AtYourAgeRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"user/%@/story", user];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlToUpdateBirthdayForPerson:(NSString *)user {
    
    NSURL *url = [AtYourAgeRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"user/%@/update_birthday", user];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlToPostUsers {
    
    NSURL *url = [AtYourAgeRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"users/add"];
    url = [url URLByAppendingPathComponent:pathString];
    return url;
}

+(NSURL *)urlToGetRelatedEventsForEvent:(NSString *)eventId {
    NSURL *url = [AtYourAgeRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"event/%@/related", eventId];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlToPostUser {
    
    NSURL *url = [AtYourAgeRequest baseUrl];
    NSString *pathString = @"user/";
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlToGetFigureWithId:(NSString *)theId {
    NSURL *url = [AtYourAgeRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"figure/%@", theId];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlToGetRandomEvents {
    NSURL *url = [AtYourAgeRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"sample-events"];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}


+(NSURL *)urlToGetEvents {
    NSURL *url = [AtYourAgeRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"events"];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(AtYourAgeRequest *)requestToGetFigureWithId:(NSString *)theId requester:(Person *)requester {
    
    AtYourAgeRequest *request = [self baseRequestForPerson:requester];
    request.urlRequest.URL = [self urlToGetFigureWithId:theId];
    request.classToParse = [Figure class];
    
    return request;
}

+(AtYourAgeRequest *)requestToGetStoryForPerson:(Person *)person {
    
    AtYourAgeRequest *request = [self baseRequestForPerson:person];
    NSURL *url = [AtYourAgeRequest storyUrlForBirthday:person.birthday Person:person.facebookId];
    request.urlRequest.URL = url;
    request.classToParse = [Event class];
    
    return request;
}

+(AtYourAgeRequest *)requestToGetRandomStories {

    AtYourAgeRequest *request = [AtYourAgeRequest baseRequest];
    NSURL *url = [AtYourAgeRequest urlToGetRandomEvents];
    [request.urlRequest setURL:url];
    return request;
}

+(AtYourAgeRequest *)requestToGetStoriesForPerson:(Person *)person {
    
    AtYourAgeRequest *request = [AtYourAgeRequest baseRequestForPerson:person];
    NSURL *url = [AtYourAgeRequest urlToGetEvents];
    request.urlRequest.URL = url;
    
    return request;
}

+(AtYourAgeRequest *)requestToSaveFacebookUsers:(NSArray *)users forPerson:(Person *)person {
    
    
    NSMutableArray *arrayOfUserIds = [NSMutableArray array];
    
    for (Person *person in users) {
        [arrayOfUserIds addObject:person.facebookId];
    }
    
    AtYourAgeRequest *request = [self baseRequestForPerson:person];
    request.urlRequest.URL = [self urlToPostUsers];
    request.urlRequest.HTTPMethod = @"POST";
    request.urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:arrayOfUserIds options:NSJSONWritingPrettyPrinted error:NULL];
    
    return request;
}

+(AtYourAgeRequest *)requestToUpdateBirthday:(NSDate *)birthday forPerson:(Person *)person {
    
    AtYourAgeRequest *request = [self baseRequestForPerson:person];
    
    NSURL *url = [AtYourAgeRequest urlToUpdateBirthdayForPerson:person.facebookId];
    NSDateFormatter *formatter = [Utility_AppSettings dateFormatterForRequest];
    NSDictionary *postDict = [NSDictionary dictionaryWithObject:[formatter stringFromDate:birthday] forKey:@"birthday"];
    
    request.urlRequest.URL = url;
    request.urlRequest.HTTPMethod = @"POST";
    request.urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:NULL];

    return request;
}

+(AtYourAgeRequest *)requestToGetRelatedEventsForEvent:(NSString *)event requester:(Person *)person {
    
    AtYourAgeRequest *request = [self baseRequestForPerson:person];
    
    NSURL *url = [AtYourAgeRequest urlToGetRelatedEventsForEvent:event];
    
    request.urlRequest.URL = url;

    return request;
}

+(AtYourAgeRequest *)baseRequest {
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    AtYourAgeRequest *request = [[AtYourAgeRequest alloc] initWithRequest:urlRequest];
    return request;
}

+(AtYourAgeRequest *)baseRequestForPerson:(Person *)person {

    AtYourAgeRequest *request = [AtYourAgeRequest baseRequest];
    NSMutableURLRequest *urlRequest = request.urlRequest;
    
    Person *primaryPerson = [[ObjectArchiveAccessor sharedInstance] primaryPerson];
    
    NSString *token = FBSession.activeSession.accessToken;
    NSString *activeFbUserId = primaryPerson.facebookId;
    
    NSDictionary *cookieDict = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token", activeFbUserId, @"activeUserId", nil];
    NSData *cookieInfo = [NSJSONSerialization dataWithJSONObject:cookieDict options:0 error:NULL];
    NSMutableString *cookieInfoString = [[NSMutableString alloc] initWithData:cookieInfo encoding:NSUTF8StringEncoding];
    [cookieInfoString replaceOccurrencesOfString:@"\"" withString:@"'" options:NSLiteralSearch range:NSMakeRange(0, [cookieInfoString length])];
    
    NSDictionary *cookieProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[[self baseUrl] host], NSHTTPCookieDomain, @"/",  NSHTTPCookiePath, cookieInfoString, NSHTTPCookieValue, @"AtYourAge", NSHTTPCookieName, nil];
//    NSLog(@"Cookie properties: %@", cookieProperties);
    
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObject:cookie]];
//    NSLog(@"URL: %@", url);
    [urlRequest setAllHTTPHeaderFields:headers];
    
    return request;
}

-(id)initWithRequest:(NSMutableURLRequest *)theRequest {
    self = [super init];
    
    if (self) {
        urlRequest = theRequest;
    }
    
    return self;
}

-(id)initWithRequest:(NSMutableURLRequest *)theRequest classToParse:(Class)theClass {
    self = [self initWithRequest:theRequest];
    
    if (self) {
        classToParse = theClass;
    }
    
    return self;
}

@end
