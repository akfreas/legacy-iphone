@interface PersistenceManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+(instancetype)sharedInstance;

+(void)setupPersistence;

+(NSManagedObjectContext *)managedObjectContext;
+(NSManagedObjectContext *)managedObjectContextForUI;
+(void)deletePersistentStore;
+(void)resetManagedObjectContext;
+(void)save;
+(void)saveContext:(NSManagedObjectContext *)context;
+(void)deleteObject:(NSManagedObject *)object;
+(void)deleteAllObjects;

-(void)resetManagedObjectContext;

-(void)deleteObjectsOfType:(__unsafe_unretained Class)class context:(NSManagedObjectContext *)context;
-(void)deleteObject:(NSManagedObject *)object;
-(void)deleteAllObjectsAndSave;
-(void)save;

@end
