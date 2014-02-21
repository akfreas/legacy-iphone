#import <XCTest/XCTest.h>
#import <CoreGraphics/CoreGraphics.h>

#import "FixtureFactory.h"
#import "EventTablePage.h"
#import "DataSyncUtility.h"
#import "EventRowCell.h"

#import "EventPersonRelation.h"
#import "Event.h"
#import "Person.h"
#import "Figure.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface EventTableTests : XCTestCase

@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) EventTablePage *tablePage;
@property (strong, nonatomic) DataSyncUtility *dataSync;

@end

@implementation EventTableTests

- (void)setUp
{
    [super setUp];
    self.events = [[FixtureFactory eventsFromFixture] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    self.tablePage = [[EventTablePage alloc] initWithFrame:CGRectZero];
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_contextForCurrentThread];
    self.dataSync = [[DataSyncUtility alloc] init];
//    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    __block BOOL finished = NO;
    [self.dataSync parseArrayOfEventsForTable:self.events completion:^{
        finished = YES;
        self.tablePage.fetchController = [EventPersonRelation MR_fetchAllSortedBy:@"person.isPrimary,event.eventId" ascending:NO withPredicate:nil groupBy:nil delegate:self.tablePage inContext:ctx];
        NSError *err = nil;
        [self.tablePage.fetchController performFetch:&err];
        if (err) {
            XCTAssert(err, @"Error encountered performing fetch on controller.");
        }
        NSArray *arr = [EventPersonRelation MR_findAllSortedBy:@"pinsToTop" ascending:YES];
        [self.tablePage reloadData];
    }];
    
    while(finished == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

-(void)testCorrectOrderingOfRows {
    
    for (int i=0; i<[self.events count]; i++) {
        
        NSDictionary *event = self.events[i];
        EventRowCell *cell = (EventRowCell *)[self.tablePage.dataSource tableView:self.tablePage cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        XCTAssert([event[@"event_id"] isEqualToNumber:cell.relation.event.eventId], @"Event with id %@ is not %@", event[@"event_id"], cell.relation.event.eventId);
    }
}

@end
