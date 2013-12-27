@protocol WebViewControlDelegate <NSObject>

@required

-(void)backButtonPressed;
-(void)forwardButtonPressed;

@end

@class Figure;

@interface WebViewControls : UIView

@property (weak, nonatomic) id <WebViewControlDelegate> delegate;
@property (nonatomic, assign) BOOL hideBackButton;
@property (nonatomic, assign) BOOL hideForwardButton;
@property (nonatomic, strong) Figure *figure;

-(void)startActivityIndicator;
-(void)stopActivityIndicator;



@end
