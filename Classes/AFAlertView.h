@interface AFAlertView : UIView

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *prompt;
@property (strong, nonatomic) NSString *leftButtonTitle;
@property (strong, nonatomic) NSString *rightButtonTitle;

@property (nonatomic, copy) void(^leftButtonActionBlock)(NSArray *addedSubViews);
@property (nonatomic, copy) void(^rightButtonActionBlock)(NSArray *addedSubViews);


-(id)initWithTitle:(NSString *)title;
-(void)insertUIComponent:(UIView *)component atIndex:(NSInteger)index;

-(void)showInView:(UIView *)view;



@end
