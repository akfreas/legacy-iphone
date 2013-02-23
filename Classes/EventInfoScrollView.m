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
        
        
        YardstickRequest *request = [YardstickRequest requestToGetEventForPerson:thePerson];
        
        connection = [[YardstickConnection alloc] initWithYardstickRequest:request];
        __block EventInfoView *eventInfoView = [[EventInfoView alloc] initWithEvent:nil];
        __block EventDetailView *detailView = [[EventDetailView alloc] initWithFrame:CGRectMake(1, 1, 100, 100)];
        detailView.wikipediaButtonTappedActionBlock = self.wikipediaButtonActionBlock;

        [connection getWithCompletionBlock:^(YardstickRequest *request, Event *result, NSError *error) {
            NSLog(@"Event Fetch Result: %@", result);
                eventInfoView.event = result;
                detailView.event = result;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addRootViewToList:infoView atIndex:currentIndex];

            [self addEventDetailViewToList:detailView adjacentToRootViewAtIndex:currentIndex];
            NSLog(@"Detail View Frame: %@", CGRectCreateDictionaryRepresentation(detailView.frame));
            currentIndex++;
            [self addRootViewToList:eventInfoView atIndex:currentIndex];
            currentIndex++;
            if (currentIndex * height > self.contentSize.height) {
                self.contentSize = CGSizeMake(self.contentSize.width, height + currentIndex * height);
            }
        });
    }
    [self layoutSubviews];
    
}

-(void)addEventDetailViewToList:(UIView *)theView adjacentToRootViewAtIndex:(NSInteger)index {
    UIView *rootView = [arrayOfPersonInfoViews objectAtIndex:index];
    CGFloat padding = 5;
    CGFloat width = 100;
    CGFloat height = 100;
    CGRect rectForEventDetailView = CGRectMake(CGRectGetMaxX(rootView.frame) + padding, CGRectGetMinY(rootView.frame), width, height);
    NSLog(@"Rootview frame: %@", CGRectCreateDictionaryRepresentation(rootView.frame));
    theView.frame = rectForEventDetailView;
    theView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self addSubview:theView];
    [theView setNeedsLayout];
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