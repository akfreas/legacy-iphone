

#include "FigureRowPageProtocol.h"

@class Event;
@class Person;
@interface EventInfoTableView : UITableView <FigureRowPageProtocol>

@property (nonatomic, weak) Person *person;
@property (nonatomic, weak) Event *event;

-(id)initWithEvent:(Event *)anEvent;

@end
