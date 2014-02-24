@interface AnalyticsUtil : NSObject

+(void)logPageTransitionTo:(NSInteger)to;
+(void)logPressFromButton:(UIButton *)button;
+(void)logRelationTapped:(EventPersonRelation *)relation;
+(void)logConnectedToFacebook;
+(void)logRelationShared:(EventPersonRelation *)relation network:(NSString *)network;

@end
