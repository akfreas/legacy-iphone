@class Person;

@interface MainScreen : UIViewController

+(MainScreen *)sharedInstance;

-(void)showAlertForNoBirthday:(Person *)thePerson completion:(void(^)(Person *person))completion cancellation:(void(^)(Person *person))cancellation;

@end
