#import "EventInfoScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "PersonInfoView.h"
#import "Person.h"
#import "YardstickRequest.h"
#import "YardstickConnection.h"
#import "EventInfoView.h"
#import "EventDetailView.h"

@implementation EventInfoScrollView {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfPersonInfoViews;
    NSFetchedResultsController *fetchedResultsController;
    YardstickConnection *connection;
}

static CGFloat height = 105;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.contentSize = CGSizeMake(320, 600);
        accessor = [ObjectArchiveAccessor sharedInstance];
        arrayOfPersonInfoViews = [[NSMutableArray alloc] init];
        [self addInfoViews];
    }
    return self;
}


-(void)addInfoViews {
    
    NSArray *people = [accessor allPersons];
    __block int currentIndex = 0;
    for (int i=0; i<[people count]; i++) {
        
        
        Person *thePerson = [people objectAtIndex:i];
        PersonInfoView *infoView = [[PersonInfoView alloc] initWithPerson:thePerson];
        infoView.frame = [self frameAtIndex:i];
        [self addRootViewToList:infoView atIndex:currentIndex];

        
        __block EventDetailView *detailView = [self addEventDetailViewAdjacentToRootViewAtIndex:currentIndex];
        
        currentIndex++;
        
        __block EventInfoView *eventInfoView = [[EventInfoView alloc] initWithEvent:nil];
        [self addRootViewToList:eventInfoView atIndex:currentIndex];
        currentIndex++;
        

        
        YardstickRequest *request = [YardstickRequest requestToGetEventForPerson:thePerson];
        
        connection = [[YardstickConnection alloc] initWithYardstickRequest:request];
        
        NSLog(@"Detail View Frame: %@", CGRectCreateDictionaryRepresentation(detailView.frame));
        

        [connection getWithCompletionBlock:^(YardstickRequest *request, Event *result, NSError *error) {
            NSLog(@"Event Fetch Result: %@", result);
            eventInfoView.event = result;
            detailView.event = result;
        }];
    }
    
    if (currentIndex * height > self.contentSize.height) {
        self.contentSize = CGSizeMake(self.contentSize.width, height + currentIndex * height);
    }
    
    [self layoutSubviews];
}

-(EventDetailView *)addEventDetailViewAdjacentToRootViewAtIndex:(NSInteger)index {
    UIView *rootView = [arrayOfPersonInfoViews objectAtIndex:index];
    CGFloat padding = 5;
    CGFloat width = 207;
    CGFloat height = 215;
    CGRect rectForEventDetailView = CGRectMake(CGRectGetMaxX(rootView.frame) + padding, CGRectGetMinY(rootView.frame), width, height);
    EventDetailView *eventDetailView = [[EventDetailView alloc] initWithFrame:rectForEventDetailView];
    NSLog(@"Rootview frame: %@", CGRectCreateDictionaryRepresentation(rectForEventDetailView));
    eventDetailView.frame = rectForEventDetailView;
//    eventDetailView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self addSubview:eventDetailView];
    [eventDetailView setNeedsLayout];
    return eventDetailView;
}

-(void)addRootViewToList:(UIView *)theView atIndex:(NSInteger)index {
    
    theView.frame = [self frameAtIndex:index];
    [self addSubview:theView];
    NSLog(@"Adding view class: %@ at index %d", [theView class], index);
        for (int i=index; i<[arrayOfPersonInfoViews count]; i++) {
        
            theView.frame = [self frameAtIndex:i-1];
            UIView *replacedView = [arrayOfPersonInfoViews objectAtIndex:i];
//            [UIView animateWithDuration:1.5 animations:^{
                theView.frame = [self frameAtIndex:i];
                replacedView.frame = [self frameAtIndex:i+1];
//            }];
//        }
    }
    [arrayOfPersonInfoViews insertObject:theView atIndex:index];
}

-(CGRect)frameAtIndex:(NSInteger)index {
    CGFloat padding = 5;
    CGFloat width = 105;

    return CGRectMake(0, (height + padding)  * index, width, height);
}

-(void)removeInfoViews {
    for (UIView *infoView in arrayOfPersonInfoViews) {
        [infoView removeFromSuperview];
    }
    [arrayOfPersonInfoViews removeAllObjects];
}

-(void)reload {
    [self removeInfoViews];
    [self addInfoViews];
}

@end