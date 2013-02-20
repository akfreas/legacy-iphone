#import "EventInfoScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "PersonInfoView.h"
#import "Person.h"

@implementation EventInfoScrollView {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfPersonInfoViews;
    NSFetchedResultsController *fetchedResultsController;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.contentSize = CGSizeMake(320, 1000);
        accessor = [ObjectArchiveAccessor sharedInstance];
        [self addInfoViews];
    }
    return self;
}


-(void)addInfoViews {
    
    NSArray *people = [accessor allPersons];
    CGFloat yValue = 0;
    CGFloat height = 120;
    for (Person *thePerson in people) {
        NSLog(@"Person: %@", thePerson.firstName);
        PersonInfoView *infoView = [[PersonInfoView alloc] initWithPerson:thePerson];
//        infoView.backgroundColor = [UIColor redColor];
        infoView.frame = CGRectMake(10, yValue, 159, height);
        yValue += height + 10;
        [self addSubview:infoView];
    }
}

@end
