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
        accessor = [ObjectArchiveAccessor sharedInstance];
        [self fetchRelatedEvents];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.allowsSelection = NO;
//        self.backgroundColor = UIColor.clearColor;
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
        indicatorLines = [[RightIndicatorLines alloc] initWithStartPoint:translatedPoint endPoint:CGPointMake(self.bounds.size.width, indicatedCellMaxY + 20)];
        [self addSubview:indicatorLines];
    }
    
    indicatorLines.person = _person;
}
#pragma mark Accessors


-(void)setPerson:(Person *)person {
    _person = person;
    indicatorLines.person = person;
    
}

-(Event *)event {
    return keyEvent;
}

-(void)setEvent:(Event *)event {
    keyEvent = event;
}

#pragma mark TableView Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < 0) {
        headerCell.nameLabelOriginYOffset = scrollView.contentOffset.y * 1.25;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        if (headerCell == nil) {
            headerCell = [[EventInfoHeaderCell alloc] initWithEvent:keyEvent];
            [self addStickLinesForCell:headerCell];
        }
        
        
        return headerCell;
    } else {
        NSInteger eventIndex = indexPath.row - 1;
        Event *theEvent = arrayOfEvents[eventIndex];
        static NSString *ReuseId = TableViewCellIdentifierForMainCell;
        EventInfoTimelineCell *timelineCell = (EventInfoTimelineCell *)[self dequeueReusableCellWithIdentifier:ReuseId];
        if (timelineCell == nil) {
            timelineCell = [[EventInfoTimelineCell alloc] initWithEvent:theEvent];
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
