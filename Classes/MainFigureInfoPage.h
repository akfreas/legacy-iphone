@class Person;
@class Event;
@class AgeIndicatorView;
@class ImageWidgetContainer;

@interface MainFigureInfoPage : UIScrollView

@property (nonatomic) Person *person;
@property (nonatomic) Event *event;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (nonatomic) IBOutlet ImageWidgetContainer *widgetContainer;

@property (nonatomic) BOOL expanded;

-(void)collapse;
-(void)collapseWithCompletion:(void(^)(BOOL expanded))completion;
-(void)expandWithRelatedEvents:(NSDictionary *)events completion:(void(^)(BOOL expanded))completion;
@end


