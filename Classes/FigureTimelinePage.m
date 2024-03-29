#import "FigureTimelinePage.h"
#import "FigureTimelineTopCell.h"
#import "FigureTimelineEventCell.h"
#import "Event.h"
#import "Figure.h"
#import "Person.h"

#import "EventPersonRelation.h"
#import "FigureTimelineTableHeader.h"

@interface FigureTimelinePage () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation FigureTimelinePage {
    
    Event *keyEvent;
    FigureTimelineTopCell *headerCell;
    
    NSInteger keyEventIndex;
    NSArray *arrayOfEvents;
}

static NSString *HeaderID = @"EventHeader";

-(id)init {
    
    self = [super init];
    if (self) {
        [self registerClass:[FigureTimelineTableHeader class] forHeaderFooterViewReuseIdentifier:HeaderID];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.allowsSelection = NO;
    }
    return self;
}


-(void)fetchRelatedEvents {
    
    arrayOfEvents = [Event eventsForFigure:_relation.event.figure inContext:[NSManagedObjectContext MR_defaultContext]];
    
    for (int i=0; i < [arrayOfEvents count]; i++) {
        
        Event *theEvent = arrayOfEvents[i];
        if ([theEvent.eventId isEqualToNumber:keyEvent.eventId]) {
            theEvent.isKeyEvent = YES;
            keyEventIndex = i;
        }
    }
}
#pragma mark Accessors
-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    keyEvent = relation.event;
    [self fetchRelatedEvents];
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

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(FigureTimelineTableHeader *)view forSection:(NSInteger)section {
//    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view prepareForReuse];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FigureTimelineTableHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderID];
    header.relation = _relation;
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
            headerCell = [[FigureTimelineTopCell alloc] init];
        }
        headerCell.relation = _relation;
        return headerCell;
    } else {
        NSInteger eventIndex = indexPath.row - 1;
        Event *theEvent = arrayOfEvents[eventIndex];
        static NSString *ReuseId = TableViewCellIdentifierForMainCell;
        FigureTimelineEventCell *timelineCell = (FigureTimelineEventCell *)[self dequeueReusableCellWithIdentifier:ReuseId];
        if (timelineCell == nil) {
            timelineCell = [[FigureTimelineEventCell alloc] initWithEvent:theEvent reuseIdentifier:ReuseId];
        } else {
            timelineCell.event = theEvent;
        }
        
        timelineCell.showAsKey = (eventIndex == keyEventIndex);
        timelineCell.isTerminalCell = (indexPath.row == [arrayOfEvents count]);
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
    [self setContentOffset:CGPointZero];
}

-(void)scrollCompleted {
    
}

@end
