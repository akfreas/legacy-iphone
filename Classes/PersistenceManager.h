@interface PersistenceManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+(instancetype)sharedInstance;

+(void)setupPersistence;

+(NSManagedObjectContext *)managedObjectContext;

+(void)deletePersistentStore;
+(void)resetManagedObjectContext;
+(void)save;
+(void)saveContext:(NSManagedObjectContext *)context;
+(void)deleteObject:(NSManagedObject *)object;
+(void)deleteAllObjects;
+(void)deleteObjectsOfType:(Class)class context:(NSManagedObjectContext *)context;

-(void)resetManagedObjectContext;
-(void)deleteObject:(NSManagedObject *)object;
-(void)deleteAllObjectsAndSave;
-(void)save;

@end
