@interface ConnectToFacebookDialogView : UIView

- (id)initForAutoLayout;
@property (nonatomic, copy) void(^dismissBlock)();
@end
