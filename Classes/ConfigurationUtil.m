#import "ConfigurationUtil.h"
#define ConfigShouldUseWikipediaKey @"use_direct_wikipedia_link"
#define ConfigShareURLRoot @"root_share_url"
@implementation ConfigurationUtil

+(BOOL)shouldUseWikipediaForSharing {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:ConfigShouldUseWikipediaKey] boolValue];
}

+(NSURL *)shareURL {
    NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:ConfigShareURLRoot]];
    return url;
}

+(void)saveConfigFromJSON:(NSDictionary *)json {
    for (id jsonKey in [json allKeys]) {
        [[NSUserDefaults standardUserDefaults] setObject:json[jsonKey] forKey:jsonKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
