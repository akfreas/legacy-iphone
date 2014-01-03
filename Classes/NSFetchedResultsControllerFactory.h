@interface NSFetchedResultsControllerFactory : NSObject

+(NSFetchedResultsController *)fetchControllerForEventTableInContext:(NSManagedObjectContext *)context;

@end
