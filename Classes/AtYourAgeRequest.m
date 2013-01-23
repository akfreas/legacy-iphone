#import "AtYourAgeRequest.h"
#import "Event.h"
#import "User.h"

@implementation AtYourAgeRequest {
    
}

@synthesize urlRequest;
@synthesize classToParse;

+(NSURL *)baseUrl {
    
    NSString *path = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ResourceUrl"];
    NSURL *url = [NSURL URLWithString:path];
    return url;
}

+(NSURL *)appendToBaseUrl:(NSString *)theUrl {
    
    NSURL *url = [[AtYourAgeRequest baseUrl] URLByAppendingPathComponent:theUrl];
    return url;
}

+(NSURL *)eventsUrlForBirthday:(NSDate *)theDate user:(NSString *)user {
    
    NSDateFormatter *formatter = [Utility_AppSettings dateFormatterForRequest];
    
    NSURL *url = [AtYourAgeRequest baseUrl];
    NSString *pathString = [NSString stringWithFormat:@"%@/event/%@", user, [formatter stringFromDate:theDate]];
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(NSURL *)urlToPostUser {
    
    NSURL *url = [AtYourAgeRequest baseUrl];
    NSString *pathString = @"user/";
    
    url = [url URLByAppendingPathComponent:pathString];
    
    return url;
}

+(AtYourAgeRequest *)requestToGetEventForUser:(User *)user {

    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    NSURL *url = [AtYourAgeRequest eventsUrlForBirthday:user.birthday user:user.facebookId];
    [urlRequest setURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSLog(@"Request: %@", url);
    
    AtYourAgeRequest *request = [[AtYourAgeRequest alloc] initWithRequest:urlRequest classToParse:[Event class]];
    
    return request;
}

+(AtYourAgeRequest *)requestToPostMainUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName birthday:(NSDate *)birthday {
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    
    NSURL *url = [AtYourAgeRequest urlToPostUser];
    
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