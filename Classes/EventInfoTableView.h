

#include "PageProtocol.h"

@class EventPersonRelation;
@interface EventInfoTableView : UITableView <PageProtocol>

@property (nonatomic, weak) EventPersonRelation *relation;

-(id)initWithRelation:(EventPersonRelation *)anEvent;

@end
