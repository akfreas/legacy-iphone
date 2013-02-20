#import "EventInfoScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "PersonInfoView.h"

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
    
    for (Person *thePerson in people) {
        PersonInfoView *infoView = [[PersonInfoView alloc] initWithPerson:thePerson];
        [self addSubview:infoView];
    }
}

@end
