@class Person;
@interface BirthdaySelectionView : UIView

@property (strong, nonatomic) id<FBGraphUser> facebookUser;
@property (strong, nonatomic) Person *person;
@property (nonatomic, copy) void(^cancelButtonBlock)();
@property (nonatomic, copy) void(^okButtonBlock)(id<FBGraphUser> graphUser);
@end
