@interface ConfigurationUtil : NSObject

+(BOOL)shouldUseWikipediaForSharing;
+(BOOL)appHasBeenUpgraded;
+(NSURL *)shareURL;
+(void)saveConfigFromJSON:(NSDictionary *)json;

@end
