#import "HorizontalContentHostingScrollView.h"
#import "Person.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "Event.h"
#import "EventPersonRelation.h"
#import "LegacyWebView.h"
#import "FacebookSignInButton.h"
#import "TopActionView.h"
#import "AppDelegate.h"
#import "EventRowCell.h"
#import "EventRowDrawerOpenBucket.h"
#import "NSFetchedResultsControllerFactory.h"
#import "DataSyncUtility.h"

#import "EventTablePage.h"

@interface EventTablePage () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@end

@implementation EventTablePage {
    CGPoint priorPoint;
    CGRect actionViewTopInitialFrame; 
    TopActionView *actionViewTop;
    NSFetchedResultsController *fetchController;
    UITableView *hostingTableView;
    UIView *headerViewWrapper;
    UIView *toolBarBackgroundView;
    UIView *lineView;
}

static NSString *ReuseID = @"CellReuseId";

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        priorPoint = CGPointZero;
        [self createHeaderWrapperView];
        self.delegate = self;
        self.dataSource = self;
        self.bounces = YES;
        self.rowHeight = FigureRowCellHeight;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        }
        [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Legacy.sqlite"];
        [self registerClass:[EventRowCell class] forCellReuseIdentifier:ReuseID];
        fetchController = [EventPersonRelation MR_fetchAllSortedBy:@"person.isPrimary" ascending:NO withPredicate:nil groupBy:nil delegate:self inContext:[NSManagedObjectContext MR_defaultContext]];
        self.contentOffset = CGPointMake(0, 0);
        NSError *err = nil;
        [fetchController performFetch:&err];
        if (err != nil) {
            NSLog(@"Error performing fetch: %@", err);  
        }
        
        [self addTopActionView];
    }
    return self;
}

#pragma mark TopActionView Control Methods

-(void)createHeaderWrapperView {
    CGRect headerWrapperFrame;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        headerWrapperFrame = CGRectMake(0, 0, self.bounds.size.width, TopActionViewHeight_non_OS7);
        
    } else {
        headerWrapperFrame = CGRectMake(0, 0, self.bounds.size.width, TopActionViewHeight_OS7);
    }

    headerViewWrapper = [[UIView alloc] initWithFrame:headerWrapperFrame];
    [self addSubview:headerViewWrapper];
}

-(void)addTopActionView {
    
    
    toolBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    if (actionViewTop == nil) {
        
        CGRect actionViewTopFrame;
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            actionViewTopInitialFrame = CGRectMake(0, -TopActionViewHeight_non_OS7, self.bounds.size.width, TopActionViewHeight_non_OS7);
            actionViewTopFrame = CGRectMake(0, 0, self.bounds.size.width, TopActionViewHeight_non_OS7);
        } else {
            [headerViewWrapper.layer insertSublayer:toolBarBackgroundView.layer below:actionViewTop.layer];
            actionViewTopInitialFrame = CGRectMake(0, -TopActionViewHeight_OS7, self.bounds.size.width, TopActionViewHeight_OS7);
            toolBarBackgroundView.backgroundColor = HeaderBackgroundColor;

            actionViewTopFrame = CGRectMake(0, 0, self.bounds.size.width, TopActionViewHeight_OS7);
        }
        actionViewTop = [[TopActionView alloc] initWithFrame:actionViewTopFrame];
        [headerViewWrapper addSubview:actionViewTop];
    }
    
    
}



-(void)addTopActionForScrollAction:(UIScrollView *)scrollView {
    
    CGPoint contentOffset = scrollView.contentOffset;
    
    CGFloat diff = priorPoint.y - contentOffset.y;
    
    if (contentOffset.y >= 0 && ((diff > 0 && actionViewTop.frame.origin.y  + diff <= 0) || (diff < 0 && actionViewTop.frame.origin.y >= -actionViewTop.frame.size.height))) {
        actionViewTop.frame = CGRectMake(0, actionViewTop.frame.origin.y + diff, actionViewTop.frame.size.width, actionViewTop.frame.size.height);
    }
    
    if (actionViewTop.frame.origin.y > -actionViewTop.frame.size.height + toolBarBackgroundView.frame.size.height) {
        lineView.alpha = 1;
        actionViewTop.tintColor = TopActionViewDefaultTintColor;
    } else {
        actionViewTop.tintColor = [UIColor clearColor];
        lineView.alpha = 0;
    }
    
    actionViewTop.isVisible = (actionViewTop.frame.origin.y > -actionViewTop.frame.size.height);
    
    
    priorPoint = scrollView.contentOffset;
}


-(void)resetFrameOnActionViewInScrollView:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y == 0) {
        [self slideDownActionView];
    } else if (actionViewTop.frame.origin.y < -actionViewTop.frame.size.height / 2) {
        [self slideUpActionView];
    } else if (actionViewTop.frame.origin.y >= -actionViewTop.frame.size.height / 2) {
        [self slideDownActionView];
    }
}

-(void)slideUpActionView {
    [UIView animateWithDuration:.2 animations:^{
        lineView.alpha = 0;
        actionViewTop.frame = CGRectSetOriginOnRect(actionViewTop.frame, 0, -actionViewTop.frame.size.height);
    }];
}

-(void)slideDownActionView {
    [UIView animateWithDuration:.2 animations:^{
        lineView.alpha = 1;
        actionViewTop.frame = CGRectSetOriginOnRect(actionViewTop.frame, 0, 0);
    }];

}

#pragma mark NSFetchedResultsController Delegate Methods

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (anObject != nil) {
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeUpdate:
                [self configureCell:(EventRowCell *)[self cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                break;
            case NSFetchedResultsChangeDelete:
                [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            default:
                break;
        }
    }

}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


#pragma mark UITableView Datasource Methods

-(EventRowCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventRowCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseID];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
}

-(void)configureCell:(EventRowCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    EventPersonRelation *eventRelation = [fetchController objectAtIndexPath:indexPath];
    cell.eventPersonRelation = eventRelation;
    if ([eventRelation.event.figure.eventsSynced isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        [DataSyncUtility syncRelatedEventForFigure:eventRelation.event.figure];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [[[fetchController sections] objectAtIndex:section] numberOfObjects];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = [[fetchController sections] count];
    return numberOfSections;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return FigureRowCellHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return headerViewWrapper;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return actionViewTopInitialFrame.size.height;
    } else {
        return 0;
    }
}

#pragma mark Notifications

#pragma mark UITableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EventPersonRelation *relation = [fetchController objectAtIndexPath:indexPath];
    if (relation.event != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EventRowTappedNotificationKey object:nil userInfo:@{@"relation": relation}];
    }
}

#pragma mark UIScrollView Delegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if ([EventRowDrawerOpenBucket hasOpenDrawers] == YES) {
        self.scrollEnabled = NO;
        [[EventRowDrawerOpenBucket sharedInstance] closeDrawers:^{
            self.scrollEnabled = YES;
            [self scrollViewDidScroll:scrollView];
        }];
    }
    if (actionViewTop != nil) {
        [self addTopActionForScrollAction:scrollView];
    }
    headerViewWrapper.frame = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, headerViewWrapper.frame.size.width, headerViewWrapper.frame.size.height);
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self resetFrameOnActionViewInScrollView:scrollView];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetFrameOnActionViewInScrollView:scrollView];
}

-(void)dealloc {
    fetchController = nil;
}

#pragma mark PageProtocol Delegate Methods

-(void)becameVisible {
    
    actionViewTop.isVisible = YES;
    if ([FBSession activeSession].state == FBSessionStateOpen) {
    } else {
        [AppDelegate openSessionWithCompletionBlock:^(FBSession *session, FBSessionState state, NSError *error) {
            if (state == FBSessionStateOpen) {
                NSLog(@"Logged into Facebook.");
            }
        }];
    }

}

-(void)scrollCompleted {

}

@end
