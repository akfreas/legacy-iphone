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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(personRowHeightChanged:) name:KeyForPersonRowContentChanged object:nil];
    }
    return self;
}


-(void)addInfoViews {
    
    NSArray *addedPeople = [accessor addedPeople];
    NSMutableArray *people = [NSMutableArray arrayWithObject:[accessor primaryPerson]];
    [people addObjectsFromArray:addedPeople];
    for (int i=0; i<[people count]; i++) {
        
        
        Person *thePerson = [people objectAtIndex:i];
        
        __block PersonRow *row = [[PersonRow alloc] initWithOrigin:CGPointMake(0, (PersonRow.height + 15) * i)];
        [arrayOfPersonRows addObject:row];
        [self addSubview:row];
        row.person = thePerson;
        
        
        self.contentSize = CGSizeMake(self.contentSize.width, (i + 1) * (PersonRow.height + 15));
    }
    
    [self setNeedsLayout];
}

-(void)personRowHeightChanged:(NSNotification *)notification {
    PersonRow *rowToResize = notification.object;
    CGFloat heightOffset = [notification.userInfo[@"delta"] floatValue];
    
    NSInteger firstIndex = [arrayOfPersonRows indexOfObject:rowToResize];
    
    self.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height + heightOffset);

        for (int i=firstIndex + 1; i<[arrayOfPersonRows count]; i++) {
            PersonRow *rowToOffset = [arrayOfPersonRows objectAtIndex:i];
            rowToOffset.frame = CGRectMake(rowToOffset.frame.origin.x, rowToOffset.frame.origin.y + heightOffset,  rowToOffset.frame.size.width, rowToOffset.frame.size.height);
        }
        
        if (heightOffset > 0) {
            self.scrollEnabled = NO;
            PersonRow *openRow = [arrayOfPersonRows objectAtIndex:firstIndex];
            [self setContentOffset:openRow.frame.origin animated:YES];
        } else {
            self.scrollEnabled = YES;
            if (firstIndex > 0 && firstIndex != [arrayOfPersonRows count] - 1) {
                PersonRow *rowAbove = [arrayOfPersonRows objectAtIndex:firstIndex - 1];
                [self setContentOffset:CGPointMake(0, CGRectGetMidY(rowAbove.frame)) animated:YES];
            }
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
