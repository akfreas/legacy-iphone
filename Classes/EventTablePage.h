#import <CoreData/CoreData.h>
#import "PageProtocol.h"


@interface EventTablePage : UITableView <PageProtocol>

@property (strong, nonatomic) NSFetchedResultsController *fetchController;

@end
