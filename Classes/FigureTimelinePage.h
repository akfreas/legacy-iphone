

#include "PageProtocol.h"

@class EventPersonRelation;
@interface FigureTimelinePage : UITableView <PageProtocol>

@property (nonatomic, strong) EventPersonRelation *relation;

@end
