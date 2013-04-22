#import "EventInfoScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "EventDescriptionView.h"
#import "PersonRow.h"
#import "ScrollViewStickLines.h"

@implementation EventInfoScrollView {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfPersonInfoViews;
    NSFetchedResultsController *fetchedResultsController;
    AtYourAgeConnection *connection;
    ScrollViewStickLines *stickLines;
}

static CGFloat height = 230;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.contentSize = CGSizeMake(320, 600);
        accessor = [ObjectArchiveAccessor sharedInstance];
        arrayOfPersonInfoViews = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wood.png"]];
        stickLines = [[ScrollViewStickLines alloc] initWithFrame:CGRectMake(0, 0, 300, self.contentSize.height)];
        [self addSubview:stickLines];
    }
    return self;
}


-(void)addInfoViews {
    
    NSArray *addedPeople = [accessor addedPeople];
    NSMutableArray *people = [NSMutableArray arrayWithObject:[accessor primaryPerson]];
    [people addObjectsFromArray:addedPeople];
    for (int i=0; i<[people count]; i++) {
        
        
        Person *thePerson = [people objectAtIndex:i];
        
        __block PersonRow *row = [[PersonRow alloc] initWithFrame:CGRectMake(20, (height + 10) * i, 320, height)];
        [arrayOfPersonInfoViews addObject:row];
        [self addSubview:row];
        row.person = thePerson;
        [row setNeedsLayout];
        
        AtYourAgeRequest *request = [AtYourAgeRequest requestToGetEventForPerson:thePerson];
        
        connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
        
        [connection getWithCompletionBlock:^(AtYourAgeRequest *request, Event *result, NSError *error) {
            NSLog(@"Event Fetch Result: %@", result);
            row.event = result;
        }];
        
        
        self.contentSize = CGSizeMake(self.contentSize.width, (i + 1) * (height + 10));
        stickLines.frame = CGRectMake(stickLines.frame.origin.x, stickLines.frame.origin.y, stickLines.frame.size.width, self.contentSize.height);
    }
    [self layoutSubviews];
    stickLines.personRowArray = [NSArray arrayWithArray:arrayOfPersonInfoViews];
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
