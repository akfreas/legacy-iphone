@interface DataSyncUtility : NSObject


+(DataSyncUtility *)sharedInstance;

-(void)sync:(void(^)())completion;
-(void)syncFacebookFriends:(void(^)())completion;

@end
