@class Event;
@interface EventInfoScrollView : UIScrollView

@property (copy) void(^wikipediaButtonActionBlock)(Event *selectedEvent);

-(void)reload;

@end
