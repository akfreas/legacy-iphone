@interface NSManagedObjectContext (ManagedObjectContextHelper)

-(void)save;
-(NSArray *)executeFetchRequest:(NSFetchRequest *)request;

@end
