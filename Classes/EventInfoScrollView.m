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
        self.backgroundColor = [UIColor colorWithRed:13/255 green:20/355 blue:20/255 alpha:1];
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
        
        __block PersonRow *row = [[PersonRow alloc] initWithFrame:CGRectMake(0, (height + 15) * i, 320, height)];
        [arrayOfPersonRows addObject:row];
        [self addSubview:row];
        row.person = thePerson;
        [row setNeedsLayout];
        
        AtYourAgeRequest *request = [AtYourAgeRequest requestToGetStoryForPerson:thePerson];
        
        connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
        
        [connection getWithCompletionBlock:^(AtYourAgeRequest *request, Event *result, NSError *error) {
            NSLog(@"Event Fetch Result: %@", result);
            row.event = result;
        }];
        
        
        UITapGestureRecognizer *touchUp = [[UITapGestureRecognizer alloc] initWithTarget:row action:@selector(toggleExpand)];
        [row addGestureRecognizer:touchUp];
        
        self.contentSize = CGSizeMake(self.contentSize.width, (i + 1) * (height + 15));
    }
    [self layoutSubviews];
}

-(void)personRowHeightChanged:(NSNotification *)notification {
    PersonRow *rowToResize = notification.object;
    CGFloat heightOffset = [notification.userInfo[@"delta"] floatValue];
    self.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height + heightOffset);
    NSInteger firstIndex = [arrayOfPersonRows indexOfObject:rowToResize];
    [UIView animateWithDuration:0.2 animations:^{
        
        for (int i=firstIndex + 1; i<[arrayOfPersonRows count]; i++) {
            PersonRow *rowToOffset = [arrayOfPersonRows objectAtIndex:i];
            rowToOffset.frame = CGRectMake(rowToOffset.frame.origin.x, rowToOffset.frame.origin.y + heightOffset,  rowToOffset.frame.size.width, rowToOffset.frame.size.height);
        }
    }];
    
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
