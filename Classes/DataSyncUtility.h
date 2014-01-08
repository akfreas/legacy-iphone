@interface DataSyncUtility : NSObject


+(DataSyncUtility *)sharedInstance;

-(void)sync:(void(^)())completion;
-(void)syncFacebookFriends:(void(^)())completion;
+(void)syncRelatedEventForFigure:(Figure *)figure;

@end
