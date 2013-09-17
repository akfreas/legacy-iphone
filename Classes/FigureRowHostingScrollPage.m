#import "LeftRightHostingScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "EventDescriptionView.h"
#import "Event.h"
#import "EventPersonRelation.h"
#import "LegacyWebView.h"
#import "FacebookSignInButton.h"
#import "TopActionView.h"
#import "AppDelegate.h"
#import "FigureRowCell.h"

#import "FigureRowHostingScrollPage.h"

@interface FigureRowHostingScrollPage () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@end

@implementation FigureRowHostingScrollPage {
    ObjectArchiveAccessor *accessor;
    CGPoint priorPoint;
    CGRect actionViewTopInitialFrame; 
    LegacyAppConnection *connection;
    TopActionView *actionViewTop;
    NSFetchedResultsController *fetchController;
}

static NSString *ReuseID = @"CellReuseId";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
        priorPoint = CGPointZero;
        accessor = [[ObjectArchiveAccessor alloc] init];        
        self.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
        self.delegate = self;
        self.dataSource = self;
        fetchController = [[ObjectArchiveAccessor sharedInstance] fetchedResultsControllerForRelations];
        fetchController.delegate = self;
        [fetchController performFetch:NULL];
    }
    return self;

}



//-(void)reload {
//    
//    eventArray = [accessor getStoredEventRelations];
//    if ([FBSession activeSession].state == FBSessionStateOpen) {
//            [self addTopActionView];
//    } else {
//        [AppDelegate openSessionWithCompletionBlock:^(FBSession *session, FBSessionState state, NSError *error) {
//            if (state == FBSessionStateOpen) {
//                    [self addTopActionView];
//            }
//        }];
//    }
//    [self reloadData];
//}

#pragma mark TopActionView Control Methods

-(void)addTopActionView {
    if (actionViewTop == nil) {
        
        actionViewTopInitialFrame = CGRectMake(0, -TopActionViewHeight, self.bounds.size.width, TopActionViewHeight);
        actionViewTop = [[TopActionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, TopActionViewHeight)];
        [self addSubview:actionViewTop];
    }
}



-(void)addTopActionForScrollAction:(UIScrollView *)scrollView {
    
    CGPoint contentOffset = scrollView.contentOffset;
    
    CGFloat diff = priorPoint.y - contentOffset.y;
    
    if (contentOffset.y >= 0 && ((diff > 0 && actionViewTop.frame.origin.y  + diff <= 0) || (diff < 0 && actionViewTop.frame.origin.y >= -actionViewTop.frame.size.height))) {
        actionViewTop.frame = CGRectMake(0, actionViewTop.frame.origin.y + diff, actionViewTop.frame.size.width, actionViewTop.frame.size.height);
    } else if (scrollView.contentOffset.y < 0) {
        actionViewTop.frame = CGRectMake(0, -scrollView.contentOffset.y, actionViewTop.frame.size.width, actionViewTop.frame.size.height);
    }
    
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
        actionViewTop.frame = CGRectSetOriginOnRect(actionViewTop.frame, 0, -actionViewTop.frame.size.height);
    }];
}

-(void)slideDownActionView {
    [UIView animateWithDuration:.2 animations:^{
        actionViewTop.frame = CGRectSetOriginOnRect(actionViewTop.frame, 0, 0);
    }];

}

#pragma mark NSFetchedResultsController Delegate Methods

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    [self configureCell:(FigureRowCell *)[self cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
    
    cell.event = eventRelation.event;
    cell.person = eventRelation.person;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[fetchController sections] objectAtIndex:0] numberOfObjects];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FigureRowPageInitialHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return actionViewTop;
}

#pragma mark UITableView Delegate Methods


#pragma mark UIScrollView Delegate Methods

//
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    
//    [self resetFrameOnActionViewInScrollView:scrollView];
//    
//}
//
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self resetFrameOnActionViewInScrollView:scrollView];
//}


#pragma mark FigureRowPageProtocol Delegate Methods

-(void)becameVisible {
    
}

-(void)scrollCompleted {
}

@end
