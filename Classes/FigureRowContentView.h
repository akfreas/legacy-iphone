@class EventPersonRelation;
@class AgeIndicatorView;
@class ImageWidgetContainer;

@interface FigureRowContentView : UIScrollView

@property (nonatomic, strong) EventPersonRelation *relation;
@property (nonatomic, readonly) ImageWidgetContainer *widgetContainer;

@end


