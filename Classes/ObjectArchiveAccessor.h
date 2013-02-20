@class Person;
@interface ObjectArchiveAccessor : NSObject

+(ObjectArchiveAccessor *)sharedInstance;


-(Person *)primaryPerson;
-(Person *)personWithFacebookId:(NSString *)facebookId;
-(NSArray *)allPersons;

-(void)setPrimaryPerson:(Person *)user;
-(Person *)addPersonWithFacebookUser:(id<FBGraphUser>)fbUser completionBlock:(void(^)(Person *thePerson))completionBlock;
-(void)addFacebookUsers:(NSArray *)users completionBlock:(void(^)())completionBlock;
-(void)getOrCreatePersonWithFacebookGraphUser:(id<FBGraphUser>)facebookUser completionBlock:(void(^)(Person *thePerson))completionBlock;
-(void)createAndSetPrimaryUser:(id<FBGraphUser>)fbUser completionBlock:(void(^)(Person *thePerson))completionBlock;

-(void)addPerson:(Person *)person;
-(void)removePerson:(Person *)person;

-(void)save;

-(NSFetchedResultsController *)fetchedResultsControllerForPeople;

@end