@class YardstickPerson;
@interface ObjectArchiveAccessor : NSObject

+(ObjectArchiveAccessor *)sharedInstance;

-(YardstickPerson *)primaryUser;
-(void)setPrimaryPerson:(YardstickPerson *)user;

-(YardstickPerson *)userWithFacebookId:(NSString *)facebookId;
-(YardstickPerson *)addFacebookPerson:(id<FBGraphUser>)user;
-(void)addFacebookUsers:(NSArray *)users;
-(YardstickPerson *)getOrCreateUserWithFacebookGraphPerson:(id<FBGraphUser>)facebookUser;
-(void)addPerson:(YardstickPerson *)user;
-(void)removePerson:(YardstickPerson *)user;
-(void)save;


@end