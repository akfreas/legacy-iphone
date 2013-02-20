@class Person;
@interface ObjectArchiveAccessor : NSObject

+(ObjectArchiveAccessor *)sharedInstance;


-(Person *)primaryPerson;
-(Person *)personWithFacebookId:(NSString *)facebookId;
-(NSArray *)allPersons;

-(void)setPrimaryPerson:(Person *)user;
-(Person *)addPersonWithFacebookUser:(id<FBGraphUser>)user;
-(void)addFacebookUsers:(NSArray *)users;
-(Person *)getOrCreatePersonWithFacebookGraphUser:(id<FBGraphUser>)facebookUser;
-(void)addPerson:(Person *)person;
-(void)removePerson:(Person *)person;

-(void)save;

-(NSFetchedResultsController *)fetchedResultsControllerForPeople;

@end