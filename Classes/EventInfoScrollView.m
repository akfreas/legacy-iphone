#import "EventInfoScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "EventDescriptionView.h"
#import "PersonRow.h"

@implementation EventInfoScrollView {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfPersonRows;
    NSFetchedResultsController *fetchedResultsController;
    AtYourAgeConnection *connection;
}

static CGFloat height = 140;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.contentSize = CGSizeMake(320, 600);
        accessor = [ObjectArchiveAccessor sharedInstance];
        arrayOfPersonRows = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wood.png"]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(personRowHeightChanged:) name:KeyForPersonRowHeightChanged object:nil];
    }
    return self;
}


-(void)addInfoViews {
    
    NSArray *addedPeople = [accessor addedPeople];
    NSMutableArray *people = [NSMutableArray arrayWithObject:[accessor primaryPerson]];
    [people addObjectsFromArray:addedPeople];
    for (int i=0; i<[people count]; i++) {
        
        
        Person *thePerson = [people objectAtIndex:i];
        
        __block PersonRow *row = [[PersonRow alloc] initWithFrame:CGRectMake(5, (height + 10) * i, 310, height)];
        [arrayOfPersonRows addObject:row];
        [self addSubview:row];
        row.person = thePerson;
        [row setNeedsLayout];
        
        AtYourAgeRequest *request = [AtYourAgeRequest requestToGetEventForPerson:thePerson];
        
        connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
        
        [connection getWithCompletionBlock:^(AtYourAgeRequest *request, Event *result, NSError *error) {
            NSLog(@"Event Fetch Result: %@", result);
            row.event = result;
        }];
        
        
        UITapGestureRecognizer *touchUp = [[UITapGestureRecognizer alloc] initWithTarget:row action:@selector(expandRow)];
        [row addGestureRecognizer:touchUp];
        
        self.contentSize = CGSizeMake(self.contentSize.width, (i + 1) * (height + 10));
    }
    [self layoutSubviews];
}

-(void)personRowHeightChanged:(NSNotification *)notification {
    PersonRow *rowToResize = notification.object;
    CGRect newFrame;
    CGFloat heightOffset = [notification.userInfo[@"delta"] floatValue];
    self.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height + newFrame.size.height - height);
    NSInteger firstIndex = [arrayOfPersonRows indexOfObject:rowToResize];

    for (int i=firstIndex + 1; i<[arrayOfPersonRows count]; i++) {
        PersonRow *rowToOffset = [arrayOfPersonRows objectAtIndex:i];
        rowToOffset.frame = CGRectMake(rowToOffset.frame.origin.x, rowToOffset.frame.origin.y + heightOffset,  rowToOffset.frame.size.width, rowToOffset.frame.size.height);
    }
    
}

-(CGRect)frameAtIndex:(NSInteger)index {
    CGFloat padding = 5;
    CGFloat width = 105;

    return CGRectMake(0, (height + padding)  * index, width, height);
}

-(void)removeInfoViews {
    for (UIView *infoView in arrayOfPersonRows) {
        [infoView removeFromSuperview];
    }
    [arrayOfPersonRows removeAllObjects];
}

-(void)reload {
    [self removeInfoViews];
    [self addInfoViews];
}

@end
