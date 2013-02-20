#import "EventInfoScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "PersonInfoView.h"
#import "Person.h"
#import "YardstickRequest.h"
#import "YardstickConnection.h"

@implementation EventInfoScrollView {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfPersonInfoViews;
    NSFetchedResultsController *fetchedResultsController;
    YardstickConnection *connection;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.contentSize = CGSizeMake(320, 1000);
        accessor = [ObjectArchiveAccessor sharedInstance];
        arrayOfPersonInfoViews = [[NSMutableArray alloc] init];
        [self addInfoViews];
    }
    return self;
}


-(void)addInfoViews {
    
    NSArray *people = [accessor allPersons];
    CGFloat yValue = 10;
    CGFloat height = 120;
    for (Person *thePerson in people) {
        PersonInfoView *infoView = [[PersonInfoView alloc] initWithPerson:thePerson];
//        infoView.backgroundColor = [UIColor redColor];
        infoView.frame = CGRectMake(10, yValue, 159, height);
        YardstickRequest *request = [YardstickRequest requestToGetEventForPerson:thePerson];
        connection = [[YardstickConnection alloc] initWithYardstickRequest:request];
        [connection getWithCompletionBlock:^(YardstickRequest *request, id result, NSError *error) {
            NSLog(@"Result: %@", result);
        }];
        yValue += height + 10;
        [self addSubview:infoView];
        [arrayOfPersonInfoViews addObject:infoView];
    }
}

-(void)removeInfoViews {
    for (PersonInfoView *infoView in arrayOfPersonInfoViews) {
        [infoView removeFromSuperview];
    }
}

-(void)reload {
    [self removeInfoViews];
    [self addInfoViews];
}

@end
