@class EventPersonRelation;
@class AgeIndicatorView;
@class ImageWidgetContainer;

@interface EventRowContentView : UIView

@property (nonatomic, strong) EventPersonRelation *relation;
@property (nonatomic, readonly) ImageWidgetContainer *widgetContainer;

@end


