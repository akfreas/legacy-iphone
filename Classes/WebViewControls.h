@protocol WebViewControlDelegate <NSObject>

@required

-(void)backButtonPressed;
-(void)forwardButtonPressed;

@end

@interface WebViewControls : UIView

@property (weak, nonatomic) id <WebViewControlDelegate> delegate;
@property (nonatomic, assign) BOOL hideBackButton;
@property (nonatomic, assign) BOOL hideForwardButton;

- (id)initWithOrigin:(CGPoint)origin;

-(void)startActivityIndicator;
-(void)stopActivityIndicator;



@end
