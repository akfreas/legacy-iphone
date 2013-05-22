@class Person;
@class Event;
@class AgeIndicatorView;
@class ImageWidgetContainer;

@interface MainFigureInfoPage : UIView 

@property (nonatomic) Person *person;
@property (nonatomic) Event *event;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (nonatomic) IBOutlet ImageWidgetContainer *widgetContainer;

@property (nonatomic) BOOL expanded;

-(void)collapse;
-(void)toggleExpandWithCompletion:(void(^)(BOOL expanded))completion;

@end


