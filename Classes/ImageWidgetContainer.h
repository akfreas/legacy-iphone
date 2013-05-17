@class Event;
@class Person;
@class ImageWidget;
@interface ImageWidgetContainer : UIView

@property (nonatomic) Event *event;
@property (nonatomic) Person *person;
@property (nonatomic) ImageWidget *widget;

-(void)expandWidget;
-(void)collapseWidget;


@end
