#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Event.h"
#import "Person.h"
#import "Figure.h"
@interface EventPersonRelation : NSManagedObject

@property (nonatomic, retain) NSNumber * pinsToTop;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Person *person;

@end
