@class EventPersonRelation;
@class AgeIndicatorView;
@class ImageWidgetContainer;

@interface EventRowContentView : UIScrollView

@property (nonatomic, strong) EventPersonRelation *relation;
@property (nonatomic, readonly) ImageWidgetContainer *widgetContainer;

@end


