

#include "FigureRowPageProtocol.h"

@class Event;
@class Person;
@interface EventInfoTableView : UITableView <FigureRowPageProtocol>

@property (nonatomic, weak) Person *person;

-(id)initWithEvent:(Event *)anEvent;

@end
