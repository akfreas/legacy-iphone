@class User;
@interface ObjectArchiveAccessor : NSObject

-(User *)primaryUser;
-(void)setPrimaryUser:(User *)user error:(NSError **)error;

-(NSMutableArray *)allUsers;
-(User *)userWithFacebookId:(NSString *)facebookId error:(NSError **)error;
-(User *)addFacebookUser:(id<FBGraphUser>)user;
-(User *)getOrCreateUserWithFacebookGraphUser:(id<FBGraphUser>)facebookUser;
-(void)addUser:(User *)user error:(NSError **)error;
-(void)removeUser:(User *)user error:(NSError **)error;
-(void)save;
-(void)refresh;

@end
