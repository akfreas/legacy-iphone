#import "EventInfoTableView.h"
#import "EventInfoHeaderCell.h"
#import "EventInfoTimelineCell.h"
#import "Event.h"
#import "Figure.h"
#import "Person.h"
#import "ObjectArchiveAccessor.h"

@interface EventInfoTableView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation EventInfoTableView {
    
    Person *person;
    Event *event;
    ObjectArchiveAccessor *accessor;
    
    
    NSArray *arrayOfEvents;
}

-(id)initWithEvent:(Event *)anEvent {
    self = [super init];
    if (self) {
        event = anEvent;
        accessor = [[ObjectArchiveAccessor alloc] init];
        [self fetchRelatedEvents];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    }
    return self;
}


-(void)fetchRelatedEvents {
    
    arrayOfEvents = [accessor eventsForFigure:event.figure];
}

#pragma mark TableView Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        static NSString *HeaderReuseId = @"HeaderTableViewCell";
        
        cell = [self dequeueReusableCellWithIdentifier:HeaderReuseId];
        if (cell == nil) {
            cell = [[EventInfoHeaderCell alloc] initWithEvent:event];
        }
        cell.frame = CGRectSetHeightForRect(100, cell.frame);
    } else {
        NSInteger eventIndex = indexPath.row - 1;
        Event *theEvent = [arrayOfEvents objectAtIndex:eventIndex];
        static NSString *ReuseId = @"mainTableViewCells";
        cell = [self dequeueReusableCellWithIdentifier:ReuseId];
        if (cell == nil) {
            cell = [[EventInfoTimelineCell alloc] initWithEvent:theEvent];
        } else {
        
            EventInfoTimelineCell *timelineCell = (EventInfoTimelineCell *)cell;
            timelineCell.event = theEvent;
        }
        cell.frame = CGRectSetHeightForRect(44, cell.frame);
        cell.backgroundColor = [UIColor orangeColor];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 200;
    } else {
        return RelatedEventsLabelHeight;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayOfEvents count] + 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end
