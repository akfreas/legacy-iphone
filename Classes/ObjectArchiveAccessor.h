@class Person;
@class Figure;
@interface ObjectArchiveAccessor : NSObject

+(ObjectArchiveAccessor *)sharedInstance;


-(Person *)primaryPerson;
-(Person *)personWithFacebookId:(NSString *)facebookId;
-(NSArray *)allPersons;
-(NSArray *)allFigures;
-(NSArray *)addedPeople;
-(NSArray *)eventsForFigure:(Figure *)figure;
-(NSArray *)getStoredEventRelations;

-(void)setPrimaryPerson:(Person *)user;
-(void)addEventAndFigureWithJson:(NSDictionary *)json;
-(void)addEventAndFigureRelationWithJson:(NSDictionary *)json;
-(Person *)addPersonWithFacebookUser:(id<FBGraphUser>)fbUser completionBlock:(void(^)(Person *thePerson))completionBlock;
-(void)addFacebookUsers:(NSArray *)users completionBlock:(void(^)())completionBlock;
-(void)getOrCreatePersonWithFacebookGraphUser:(id<FBGraphUser>)facebookUser completionBlock:(void(^)(Person *thePerson))completionBlock;
-(void)createAndSetPrimaryUser:(id<FBGraphUser>)fbUser completionBlock:(void(^)(Person *thePerson))completionBlock;

-(void)addPerson:(Person *)person;
-(void)removePerson:(Person *)person;
-(void)clearEventsAndFiguresAndSave;
-(void)save;


-(NSFetchedResultsController *)fetchedResultsControllerForRelations;
-(NSManagedObjectContext *)managedObjectContext;

@end