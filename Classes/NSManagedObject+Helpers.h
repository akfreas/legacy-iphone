@interface NSManagedObject (Helpers)


+(instancetype)newInContext:(NSManagedObjectContext *)context;

+(NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+(instancetype)objectWithObjectID:(NSManagedObjectID *)objectId inContext:(NSManagedObjectContext *)context;
+(instancetype)objectWithObjectID:(NSManagedObjectID *)objectId;
+(NSArray *)objectsWithValue:(id)value forKey:(id)key inContext:(NSManagedObjectContext *)context;
+(NSFetchRequest *)baseFetchRequest;
-(void)saveInContext:(NSManagedObjectContext *)context;
-(void)save;
-(void)delete;

@end
