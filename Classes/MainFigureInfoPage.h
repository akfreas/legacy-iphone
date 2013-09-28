#import "FigureRowPageProtocol.h"

@class Person;
@class Event;
@class AgeIndicatorView;
@class ImageWidgetContainer;

@interface MainFigureInfoPage : UIScrollView <FigureRowPageProtocol>

@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) Event *event;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (nonatomic) IBOutlet ImageWidgetContainer *widgetContainer;

@property (nonatomic) BOOL expanded;

-(void)collapse;
-(void)collapseWithCompletion:(void(^)(BOOL expanded))completion;
-(void)expandWithRelatedEvents:(NSArray *)events completion:(void(^)(BOOL expanded))completion ;
@end


