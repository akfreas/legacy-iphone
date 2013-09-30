@interface FacebookUtils : NSObject

+(void)getAndSavePrimaryUser:(void(^)())completion;
+(void)startFBLoginProcess:(void(^)())completion;
+(void)loginWithFacebook:(void(^)())completion;
@end
