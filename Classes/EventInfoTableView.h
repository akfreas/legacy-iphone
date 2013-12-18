

#include "PageProtocol.h"

@class Event;
@class Person;
@interface EventInfoTableView : UITableView <PageProtocol>

@property (nonatomic, weak) Person *person;
@property (nonatomic, weak) Event *event;

-(id)initWithEvent:(Event *)anEvent;

@end
