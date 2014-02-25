@interface ConfigurationUtil : NSObject

+(BOOL)shouldUseWikipediaForSharing;
+(NSURL *)shareURL;
+(void)saveConfigFromJSON:(NSDictionary *)json;

@end
