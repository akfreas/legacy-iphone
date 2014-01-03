#import "NSFetchedResultsControllerFactory.h"
#import "EventPersonRelation.h"
#import "PersistenceManager.h"

@implementation NSFetchedResultsControllerFactory




+(NSArray *)eventRelationSortDescriptors {
    
    NSSortDescriptor *pinToTopSorter = [NSSortDescriptor sortDescriptorWithKey:@"pinsToTop" ascending:NO];
    NSSortDescriptor *meSorter = [NSSortDescriptor sortDescriptorWithKey:@"person.isPrimary" ascending:NO];
    NSSortDescriptor *friendSorter = [NSSortDescriptor sortDescriptorWithKey:@"person.isFacebookUser" ascending:NO];
    NSSortDescriptor *bdaySorter = [NSSortDescriptor sortDescriptorWithKey:@"person.birthday" ascending:NO];
    return @[pinToTopSorter, meSorter, friendSorter, bdaySorter];// ageYearSorter, ageMonthSorter, ageDaySorter];
}


+(NSFetchedResultsController *)fetchControllerForEventTableInContext:(NSManagedObjectContext *)context {
    if (context == nil) {
        context = [PersistenceManager managedObjectContext];
    }
    NSFetchRequest *relationFetchRequest = [EventPersonRelation baseFetchRequest];
    relationFetchRequest.sortDescriptors = [self eventRelationSortDescriptors];
    NSFetchedResultsController *fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:relationFetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    return fetchController;
}
@end
