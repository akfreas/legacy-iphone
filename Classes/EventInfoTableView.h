#include "FigureRowPageProtocol.h"

@class Event;
@interface EventInfoTableView : UITableView <FigureRowPageProtocol>

-(id)initWithEvent:(Event *)anEvent;

@end
