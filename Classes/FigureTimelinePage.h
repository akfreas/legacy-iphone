

#include "PageProtocol.h"

@class EventPersonRelation;
@interface FigureTimelinePage : UITableView <PageProtocol>

@property (nonatomic, weak) EventPersonRelation *relation;

-(id)initWithRelation:(EventPersonRelation *)anEvent;

@end
