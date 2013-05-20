@class Person;
@class Event;
@class AgeIndicatorView;

@interface MainFigureInfoPage : UIView 

@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) IBOutlet UIView *view;

@property (nonatomic) BOOL expanded;

-(void)collapse;
-(void)toggleExpand;

@end


