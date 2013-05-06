@class Person;
@class Event;
@class AgeIndicatorView;

@interface PersonRow : UIView 

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) Person *person;

@property (strong, nonatomic) IBOutlet AgeIndicatorView *ageIndicator;

-(void)expandRow;

@end
