@class Event;
@class Person;
@interface ImageWidgetContainer : UIView

@property (nonatomic) Event *event;
@property (nonatomic) Person *person;

-(void)expandWidget;
-(void)collapseWidget;


@end