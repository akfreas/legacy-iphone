@class Person;
@class Event;
@class AgeIndicatorView;

@interface PersonRow : UIView 

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) IBOutlet UIView *view;

@property (strong, nonatomic) IBOutlet AgeIndicatorView *ageIndicator;
@property (nonatomic) BOOL expanded;

-(void)expandWithCompletion:(void(^)(NSNumber *))completionBlock;
-(void)collapse;
-(void)toggleExpand;

@end


