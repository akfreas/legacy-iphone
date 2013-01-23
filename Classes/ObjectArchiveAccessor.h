@class User;
@interface ObjectArchiveAccessor : NSObject

-(User *)primaryUser;
-(void)setPrimaryUser:(User *)user error:(NSError *)error;

-(NSMutableArray *)allUsers;
-(User *)userWithFacebookId:(NSString *)facebookId error:(NSError *)error;
-(void)addUser:(User *)user error:(NSError *)error;
-(void)addFacebookUser:(id<FBGraphUser>)user;
-(void)removeUser:(User *)user error:(NSError *)error;

@end
