@class Person;
@class Event;
@class AgeIndicatorView;

@interface MainFigureInfoPage : UIView 

@property (nonatomic) Person *person;
@property (nonatomic) Event *event;
@property (strong, nonatomic) IBOutlet UIView *view;

@property (nonatomic) BOOL expanded;

-(void)collapse;
-(void)toggleExpand;

@end


