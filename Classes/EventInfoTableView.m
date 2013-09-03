#import "EventInfoTableView.h"
#import "EventInfoHeaderCell.h"
#import "EventInfoTimelineCell.h"
#import "Event.h"
#import "Figure.h"
#import "Person.h"
#import "ObjectArchiveAccessor.h"
#import "RightIndicatorLines.h"

@interface EventInfoTableView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation EventInfoTableView {
    
    Person *person;
    Event *keyEvent;
    ObjectArchiveAccessor *accessor;
    RightIndicatorLines *indicatorLines;
    EventInfoHeaderCell *headerCell;
    
    NSInteger keyEventIndex;
    NSArray *arrayOfEvents;
}

-(id)initWithEvent:(Event *)anEvent {
    self = [super init];
    if (self) {
        keyEvent = anEvent;
        accessor = [[ObjectArchiveAccessor alloc] init];
        [self fetchRelatedEvents];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
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

-(void)addStickLinesForCell:(EventInfoHeaderCell *)cell {
    
    if (indicatorLines == nil) {
        CGFloat indicatedCellMaxY = cell.frame.size.height + RelatedEventsLabelHeight * (keyEventIndex );
        CGPoint translatedPoint = [self convertPoint:cell.pointForLines toView:self];
        
        indicatorLines  = [RightIndicatorLines new];
        indicatorLines = [[RightIndicatorLines alloc] initWithStartPoint:translatedPoint endPoint:CGPointMake(self.bounds.size.width, indicatedCellMaxY)];
        [self addSubview:indicatorLines];
    }
    
    indicatorLines.person = person;
    
    
    
}

#pragma mark TableView Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < 0) {
        headerCell.nameLabelOriginYOffset = scrollView.contentOffset.y * 1.25;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (headerCell == nil) {
            headerCell = [[EventInfoHeaderCell alloc] initWithEvent:keyEvent];
        }
    }
    return headerCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 200.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    NSInteger eventIndex = indexPath.row;
    Event *theEvent = arrayOfEvents[eventIndex];
    static NSString *ReuseId = TableViewCellIdentifierForMainCell;
    cell = [self dequeueReusableCellWithIdentifier:ReuseId];
    if (cell == nil) {
        cell = [[EventInfoTimelineCell alloc] initWithEvent:theEvent];
    } else {
        EventInfoTimelineCell *timelineCell = (EventInfoTimelineCell *)cell;
        timelineCell.event = theEvent;
    }
    
    if (eventIndex == keyEventIndex) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    cell.frame = CGRectSetHeightForRect(RelatedEventsLabelHeight, cell.frame);
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return RelatedEventsLabelHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayOfEvents count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark FigureRowPageProtocol Delegate Methods

-(void)becameVisible {
    
}

-(void)scrollCompleted {
    
}

@end
