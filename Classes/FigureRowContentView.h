@class Person;
@class Event;
@class AgeIndicatorView;
@class ImageWidgetContainer;

@interface FigureRowContentView : UIScrollView

@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) Event *event;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (nonatomic) IBOutlet ImageWidgetContainer *widgetContainer;

@end


