#import "LeftRightHostingScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "Event.h"
#import "EventPersonRelation.h"
#import "LegacyWebView.h"
#import "FacebookSignInButton.h"
#import "TopActionView.h"
#import "AppDelegate.h"
#import "FigureRowCell.h"
#import "AFAlertView.h"

#import "FigureRowHostingScrollPage.h"

@interface FigureRowHostingScrollPage () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@end

@implementation FigureRowHostingScrollPage {
    CGPoint priorPoint;
    CGRect actionViewTopInitialFrame; 
    LegacyAppConnection *connection;
    TopActionView *actionViewTop;
    NSFetchedResultsController *fetchController;
    UITableView *hostingTableView;
    UIView *headerViewWrapper;
    UIToolbar *toolBar;
    UIView *lineView;
    UIView *clearView;
}

static NSString *ReuseID = @"CellReuseId";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
        priorPoint = CGPointZero;
        [self createHeaderWrapperView];
        self.delegate = self;
        self.dataSource = self;
        self.bounces = NO;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        }
        fetchController = [[ObjectArchiveAccessor sharedInstance] fetchedResultsControllerForRelations];
        fetchController.delegate = self;
        self.contentOffset = CGPointMake(0, TopActionViewHeight_OS7);
        [fetchController performFetch:NULL];
    }
    return self;
}

-(void)addTopLine {
    lineView = [[UIView alloc] initWithFrame:CGRectMake(15, actionViewTop.frame.size.height - 1, 320 - 30 , .5)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
    [actionViewTop addSubview:lineView];
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
    
    
    if (actionViewTop == nil) {
        
        CGRect actionViewTopFrame;
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            actionViewTopInitialFrame = CGRectMake(0, -TopActionViewHeight_non_OS7, self.bounds.size.width, TopActionViewHeight_non_OS7);
            actionViewTopFrame = CGRectMake(0, 0, self.bounds.size.width, TopActionViewHeight_non_OS7);
        } else {
            actionViewTopInitialFrame = CGRectMake(0, -TopActionViewHeight_OS7, self.bounds.size.width, TopActionViewHeight_OS7);
            actionViewTopFrame = CGRectMake(0, 0, self.bounds.size.width, TopActionViewHeight_OS7);
        }
        actionViewTop = [[TopActionView alloc] initWithFrame:actionViewTopFrame];
        [headerViewWrapper addSubview:actionViewTop];
        [self addTopLine];
    }
    
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [toolBar setBarTintColor:[UIColor colorWithWhite:1 alpha:.85]];
    [headerViewWrapper.layer insertSublayer:toolBar.layer below:actionViewTop.layer];
}



-(void)addTopActionForScrollAction:(UIScrollView *)scrollView {
    
    CGPoint contentOffset = scrollView.contentOffset;
    
    CGFloat diff = priorPoint.y - contentOffset.y;
    
    if (contentOffset.y >= 0 && ((diff > 0 && actionViewTop.frame.origin.y  + diff <= 0) || (diff < 0 && actionViewTop.frame.origin.y >= -actionViewTop.frame.size.height))) {
        actionViewTop.frame = CGRectMake(0, actionViewTop.frame.origin.y + diff, actionViewTop.frame.size.width, actionViewTop.frame.size.height);
    }
    
    if (actionViewTop.frame.origin.y > -actionViewTop.frame.size.height + toolBar.frame.size.height) {
        lineView.alpha = 1;
//        toolBar.hidden = YES;
        actionViewTop.tintColor = TopActionViewDefaultTintColor;
    } else {
        actionViewTop.tintColor = [UIColor clearColor];
        lineView.alpha = 0;
//        toolBar.hidden = NO;
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
                [self insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeUpdate:
                [self configureCell:(FigureRowCell *)[self cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            case NSFetchedResultsChangeDelete:
                [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
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

-(FigureRowCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FigureRowCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseID];
    
    if (cell == nil) {
        cell = [[FigureRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseID];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
}

-(void)configureCell:(FigureRowCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    EventPersonRelation *eventRelation = [fetchController objectAtIndexPath:indexPath];
    cell.eventPersonRelation = eventRelation;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [[[fetchController sections] objectAtIndex:section] numberOfObjects];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = [[fetchController sections] count];
    return numberOfSections;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && [[fetchController sections] count] > 1) {
        return NoEventFigureRowHeight;
    } else {
        return FigureRowPageInitialHeight;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return headerViewWrapper;
    if (section == 0) {
        clearView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, headerViewWrapper.frame.size.height)];
        clearView.backgroundColor = [UIColor clearColor];
        clearView.tag = 7;
        return clearView;
    }
    return nil;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *ourHit = [super hitTest:point withEvent:event];
    if (ourHit == clearView) {
        [actionViewTop addFriendsButtonTappedAction];
        return actionViewTop;
    } else {
        return ourHit;
    }
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


#pragma mark UIScrollView Delegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
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

#pragma mark FigureRowPageProtocol Delegate Methods

-(void)becameVisible {
    
    [self addTopActionView];
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
