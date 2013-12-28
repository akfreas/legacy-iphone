#import "EventInfoTableView.h"
#import "EventInfoHeaderCell.h"
#import "EventInfoTimelineCell.h"
#import "Event.h"
#import "Figure.h"
#import "Person.h"
#import "ObjectArchiveAccessor.h"
#import "EventPersonRelation.h"
#import "EventInfoTableHeader.h"

@interface EventInfoTableView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation EventInfoTableView {
    
    Event *keyEvent;
    ObjectArchiveAccessor *accessor;
    EventInfoHeaderCell *headerCell;
    
    NSInteger keyEventIndex;
    NSArray *arrayOfEvents;
}

static NSString *HeaderID = @"EventHeader";

-(id)initWithRelation:(EventPersonRelation *)aRelation {
    
    self = [super init];
    if (self) {
        self.relation = aRelation;
        keyEvent = aRelation.event;
        accessor = [ObjectArchiveAccessor sharedInstance];
        [self fetchRelatedEvents];
        [self registerClass:[EventInfoTableHeader class] forHeaderFooterViewReuseIdentifier:HeaderID];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.allowsSelection = NO;
    }
    return self;
}


-(void)fetchRelatedEvents {
    
    arrayOfEvents = [accessor eventsForFigure:keyEvent.figure];
    
    for (int i=0; i < [arrayOfEvents count]; i++) {
        
        Event *theEvent = arrayOfEvents[i];
        if ([theEvent.eventId isEqualToNumber:keyEvent.eventId]) {
            theEvent.isKeyEvent = YES;
            keyEventIndex = i;
        }
    }
}

#pragma mark TableView Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < 0) {
        headerCell.nameLabelOriginYOffset = scrollView.contentOffset.y * 1.25;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 64;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(EventInfoTableHeader *)view forSection:(NSInteger)section {
//    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view prepareForReuse];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    EventInfoTableHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderID];
    header.relation = self.relation;
    return header;
}



-(CGSize)intrinsicContentSize {
    return CGSizeMake(320, 480);
}
-(void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
}

-(void)layoutSubviews {
    [super layoutSubviews];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        if (headerCell == nil) {
            headerCell = [[EventInfoHeaderCell alloc] initWithRelation:self.relation];
        }
        
        return headerCell;
    } else {
        NSInteger eventIndex = indexPath.row - 1;
        Event *theEvent = arrayOfEvents[eventIndex];
        static NSString *ReuseId = TableViewCellIdentifierForMainCell;
        EventInfoTimelineCell *timelineCell = (EventInfoTimelineCell *)[self dequeueReusableCellWithIdentifier:ReuseId];
        if (timelineCell == nil) {
            timelineCell = [[EventInfoTimelineCell alloc] initWithEvent:theEvent reuseIdentifier:ReuseId];
        } else {
            timelineCell.event = theEvent;
        }
        
        if (eventIndex == keyEventIndex) {
            timelineCell.showAsKey = YES;
        } else {
            timelineCell.showAsKey = NO;
        }
        
        timelineCell.frame = CGRectSetHeightForRect(RelatedEventsLabelHeight, timelineCell.frame);
        return timelineCell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return EventInfoHeaderCellHeight;
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

#pragma mark PageProtocol Delegate Methods

-(void)becameVisible {
    
}

-(void)scrollCompleted {
    
}

@end
