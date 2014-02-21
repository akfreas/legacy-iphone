@class Figure;

@interface DataSyncUtility : NSObject

+(DataSyncUtility *)sharedInstance;

-(void)sync:(void(^)())completion;
-(void)syncFacebookFriends:(void(^)())completion;
+(void)syncRelatedEventForFigure:(Figure *)figure;
-(void)parseArrayOfEventsForTable:(NSArray *)events;
-(void)parseArrayOfEventsForTable:(NSArray *)events completion:(void (^)())completionBlock;

@end
