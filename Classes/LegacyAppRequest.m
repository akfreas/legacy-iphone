#import "LegacyAppRequest.h"
#import "Event.h"
#import "Person.h"
#import "Figure.h"

#import "Utility_AppSettings.h"
#import <TargetConditionals.h>
@implementation LegacyAppRequest {
    
}

@synthesize urlRequest;
@synthesize classToParse;

+(NSURL *)baseUrl {
    
#if TARGET_IPHONE_SIMULATOR
    NSString *path = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DebugResourceUrl"];
#else
    NSString *path = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ResourceUrl"];
#endif
    NSURL *url = [NSURL URLWithString:path];
    return url;
}

+(NSURL *)appendToBaseUrl:(NSString *)theUrl {
    
    NSURL *url = [[LegacyAppRequest baseUrl] URLByAppendingPathComponent:theUrl];
    return url;
}

+(NSURL *)urlToUpdateBirthdayForPerson:(NSString *)user {
    
    NSURL *url = [LegacyAppRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"user/%@/update_birthday", user];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlToPostUsers {
    
    NSURL *url = [LegacyAppRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"users/add"];
    url = [url URLByAppendingPathComponent:pathString];
    return url;
}

+(NSURL *)urlToPostUser {
    
    NSURL *url = [LegacyAppRequest baseUrl];
    NSString *pathString = @"user/";
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlForEventsForFigure:(Figure *)figure {
    
    NSURL *url = [LegacyAppRequest baseUrl];
    
    NSString *pathString = [NSString stringWithFormat:@"figure/%@/events", figure.id];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlToDeletePerson:(Person *)person {
    NSURL *url = [LegacyAppRequest baseUrl];
    
    NSString *pathString = [NSString stringWithFormat:@"user/%@/delete", person.facebookId];
    
    url = [url URLByAppendingPathComponent:pathString];
    return url;
}

+(NSURL *)urlToGetEventForPerson:(Person *)person {
    NSURL *url = [self baseUrl];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"user/%@/event", person.facebookId]];
    return url;
}

+(NSURL *)urlToAddPerson:(Person *)person {
    NSURL *url = [LegacyAppRequest baseUrl];
    
    NSString *pathString = [NSString stringWithFormat:@"user/%@/add", person.facebookId];
    
    url = [url URLByAppendingPathComponent:pathString];
    return url;
}

+(NSURL *)urlToGetRandomEvents {
    NSURL *url = [LegacyAppRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"sample-events"];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}


+(NSURL *)urlToGetEvents {
    NSURL *url = [LegacyAppRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"events"];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlToPostDeviceInfo {
    
    NSURL *url = [LegacyAppRequest baseUrl];
    url = [url URLByAppendingPathComponent:@"device/information"];
    return url;
}

+(LegacyAppRequest *)requestToPostDeviceInformation:(NSDictionary *)deviceInfo person:(Person *)person {
    
    LegacyAppRequest *request = [LegacyAppRequest baseRequestForPerson:person];
    
    request.urlRequest.URL = [self urlToPostDeviceInfo];
    request.urlRequest.HTTPMethod = @"POST";
    request.urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:NULL];
    
    return request;
}

+(LegacyAppRequest *)requestToGetAllStoriesForPrimaryPerson:(Person *)person {
    
    LegacyAppRequest *request = [LegacyAppRequest baseRequestForPerson:person];
    NSURL *url = [LegacyAppRequest urlToGetEvents];
    request.urlRequest.URL = url;
    
    return request;
}


+(LegacyAppRequest *)requestToGetEventForPerson:(Person *)person {
    LegacyAppRequest *request = [LegacyAppRequest baseRequestForPerson:nil];
    NSURL *url = [LegacyAppRequest urlToGetEventForPerson:person];
    request.urlRequest.URL = url;
    return request;
}

+(LegacyAppRequest *)requestToSaveFacebookUsers:(NSArray *)users forPerson:(Person *)person {
    
    
    NSMutableArray *arrayOfUserInfo = [NSMutableArray array];
    
    for (Person *ourPerson in users) {
        [arrayOfUserInfo addObject:[self dictionaryForPerson:ourPerson]];
    }
    
    LegacyAppRequest *request = [self baseRequestForPerson:person];
    request.urlRequest.URL = [self urlToPostUsers];
    request.urlRequest.HTTPMethod = @"POST";
    request.urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:arrayOfUserInfo options:NSJSONWritingPrettyPrinted error:NULL];
    
    return request;
}

+(NSDictionary *)dictionaryForPerson:(Person *)ourPerson {
    NSDateFormatter *formatter = [Utility_AppSettings dateFormatterForRequest];
    return @{@"facebook_id" : ourPerson.facebookId, @"birthday" : [formatter stringFromDate:ourPerson.birthday]};
}

+(LegacyAppRequest *)requestToUpdateBirthday:(NSDate *)birthday forPerson:(Person *)person {
    
    LegacyAppRequest *request = [self baseRequestForPerson:person];
    
    NSURL *url = [LegacyAppRequest urlToUpdateBirthdayForPerson:person.facebookId];
    NSDateFormatter *formatter = [Utility_AppSettings dateFormatterForRequest];
    NSDictionary *postDict = [NSDictionary dictionaryWithObject:[formatter stringFromDate:birthday] forKey:@"birthday"];
    
    request.urlRequest.URL = url;
    request.urlRequest.HTTPMethod = @"POST";
    request.urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:NULL];

    return request;
}



+(LegacyAppRequest *)requestToGetAllEventsForFigure:(Figure *)figure {
    
    LegacyAppRequest *request = [self baseRequest];
    
    request.urlRequest.URL = [self urlForEventsForFigure:figure];
    
    return request;
}

+(LegacyAppRequest *)baseRequest {
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    LegacyAppRequest *request = [[LegacyAppRequest alloc] initWithRequest:urlRequest];
    return request;
}

+(LegacyAppRequest *)baseRequestForPerson:(Person *)person {

    if (person == nil) {
        person = [Person primaryPersonInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }
    LegacyAppRequest *request = [LegacyAppRequest baseRequest];
    NSMutableURLRequest *urlRequest = request.urlRequest;

    NSString *token = FBSession.activeSession.accessTokenData.accessToken;
    NSString *activeFbUserId = person.facebookId;
    
    NSDictionary *cookieDict = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token", activeFbUserId, @"activeUserId", nil];
    NSData *cookieInfo = [NSJSONSerialization dataWithJSONObject:cookieDict options:0 error:NULL];
    NSMutableString *cookieInfoString = [[NSMutableString alloc] initWithData:cookieInfo encoding:NSUTF8StringEncoding];
    [cookieInfoString replaceOccurrencesOfString:@"\"" withString:@"'" options:NSLiteralSearch range:NSMakeRange(0, [cookieInfoString length])];
    
    NSDictionary *cookieProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[[self baseUrl] host], NSHTTPCookieDomain, @"/",  NSHTTPCookiePath, cookieInfoString, NSHTTPCookieValue, @"LegacyApp", NSHTTPCookieName, nil];
//    NSLog(@"Cookie properties: %@", cookieProperties);
    
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObject:cookie]];
//    NSLog(@"URL: %@", url);
    [urlRequest setAllHTTPHeaderFields:headers];
    
    return request;
}

+(LegacyAppRequest *)requestToDeletePerson:(Person *)person {
    LegacyAppRequest *request = [LegacyAppRequest baseRequestForPerson:nil];
    
    NSURL *urlToDelete = [LegacyAppRequest urlToDeletePerson:person];
    request.urlRequest.URL = urlToDelete;
    
    return request;
}

+(LegacyAppRequest *)requestToAddPerson:(Person *)person {
    LegacyAppRequest *request = [LegacyAppRequest baseRequestForPerson:nil];
    NSURL *urlToDelete = [self urlToAddPerson:person];
    request.urlRequest.URL = urlToDelete;
    
    NSError *err = nil;
    NSDictionary *dict = [self dictionaryForPerson:person];
    request.urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
    request.urlRequest.HTTPMethod = @"POST";
    if (err != nil) {
        NSLog(@"Error serializing person to delete: %@ %@", person, err);
    }
    return request;
}

+(LegacyAppRequest *)requestToVerifyPasscode:(NSString *)passcode {
    LegacyAppRequest *request = [LegacyAppRequest baseRequest];
    request.urlRequest.URL = [[LegacyAppRequest baseUrl] URLByAppendingPathComponent:[NSString stringWithFormat:@"/passcode/verify/%@", passcode]];
    return request;
}

+(LegacyAppRequest *)requestToGetConfiguration {
    LegacyAppRequest *request = [LegacyAppRequest baseRequest];
    request.urlRequest.URL = [[LegacyAppRequest baseUrl] URLByAppendingPathComponent:@"configuration"];
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
