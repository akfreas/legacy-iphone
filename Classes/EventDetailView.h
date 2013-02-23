@class Event;
@interface EventDetailView : UIView


@property (nonatomic) Event *event;
@property (copy) void(^wikipediaButtonTappedActionBlock)(Event *selectedEvent);
@end

