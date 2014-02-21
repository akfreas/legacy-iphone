#import <CoreData/CoreData.h>
#import "PageProtocol.h"


@interface EventTablePage : UITableView <PageProtocol, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchController;

@end
