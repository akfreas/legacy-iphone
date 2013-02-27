#import "AFAlertView.h"
#define PADDING 10

@implementation AFAlertView {
    
    IBOutlet UIButton *leftButton;
    IBOutlet UIButton *rightButton;
    IBOutlet UITextView *descriptionTextView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *promptLabel;
    
    IBOutlet UIView *view;
    IBOutlet UIView *alertDialogView;
    
    
    UIView *superView;
    NSMutableArray *addedSubViews;
}

-(id)initWithTitle:(NSString *)title {
    self = [super init];
    
    if (self) {
        self.title = title;
        [self addObservers];
        [[NSBundle mainBundle] loadNibNamed:@"AFAlertView" owner:self options:nil];
        [self addSubview:view];
        addedSubViews = [NSMutableArray array];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"AFAlertView" owner:self options:nil];
    alertDialogView.frame = CGRectMake(0, 0, 320, 200);
    [view addSubview:alertDialogView];
}

-(void)presentingKeyboard:(NSNotification *)notification {
    NSDictionary *userDict = notification.userInfo;
    [UIView animateWithDuration:[userDict[UIKeyboardAnimationDurationUserInfoKey] integerValue] animations:^{
        
        CGRect kbdRect = [userDict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        alertDialogView.frame = CGRectMake(0, kbdRect.size.height - alertDialogView.frame.size.height, CGRectGetWidth(alertDialogView.frame), CGRectGetWidth(alertDialogView.frame));
    }];
}

-(void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentingKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissingKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dismissingKeyboard:(NSNotification *)notification {
    
}

-(void)configureLeftButton {
    
    if (self.leftButtonTitle != nil) {
        
        leftButton.hidden = NO;
        [leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [leftButton setTitle:self.leftButtonTitle forState:UIControlStateNormal];
        
        
        leftButton.backgroundColor = [UIColor clearColor];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 20, 0, 20);

        [leftButton setBackgroundImage:[[UIImage imageNamed:@"button.png"] resizableImageWithCapInsets:insets]
                              forState:UIControlStateNormal];
        
        [leftButton setBackgroundImage:[[UIImage imageNamed:@"button-pressed.png"] resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
        leftButton.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:17];
    }
}

-(void)configureRightButton {
    
    if (self.rightButtonTitle != nil) {

        rightButton.hidden = NO;
        [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitle:self.rightButtonTitle forState:UIControlStateNormal];
        rightButton.backgroundColor = [UIColor clearColor];
        
        [rightButton setBackgroundImage:[[UIImage imageNamed:@"button.png"] stretchableImageWithLeftCapWidth:15
                                                                                                  topCapHeight:15] forState:UIControlStateNormal];
        
        [rightButton setBackgroundImage:[[UIImage imageNamed:@"button-pressed.png"] stretchableImageWithLeftCapWidth:5                                                                                                        topCapHeight:20] forState:UIControlStateHighlighted];
        rightButton.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:17];
    }
}

-(void)configurePromptLabel {
    
    if (self.prompt != nil) {
        CGSize constraint = CGSizeMake(promptLabel.frame.size.width, self.frame.size.height);
        CGSize promptSize = [self.prompt sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        
        promptLabel.numberOfLines = ceilf(promptSize.height / 18);
        promptLabel.frame = CGRectMake(promptLabel.frame.origin.x, promptLabel.frame.origin.y, promptSize.width, promptSize.height + PADDING);
        
    } else {
        promptLabel.hidden = YES;
    }
}

-(void)configureAlertDialog {
    
    alertDialogView.frame = CGRectMake(0, self.frame.size.height, CGRectGetWidth(alertDialogView.frame), CGRectGetHeight(alertDialogView.frame));
    descriptionTextView.text = self.description;
    titleLabel.text = self.title;
    promptLabel.text = self.prompt;
}

-(void)insertUIComponent:(UIView *)component atIndex:(NSInteger)index {
    
    [addedSubViews addObject:component];
    [alertDialogView insertSubview:component atIndex:index];
}



-(void)resizeAlertViewForText {
    
    
    CGSize constraint = CGSizeMake(descriptionTextView.frame.size.width, self.frame.size.height);
    CGSize descriptionSize = [self.description sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0]
                                                   constrainedToSize:constraint
                                              lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat xTextView = CGRectGetMinX(descriptionTextView.frame);
    CGFloat yTextView = CGRectGetMinY(titleLabel.frame);
    CGFloat widthTextView = CGRectGetWidth(descriptionTextView.frame);
    CGFloat heightTextView = descriptionSize.height + PADDING;
    
    descriptionTextView.frame = CGRectMake(xTextView, yTextView, widthTextView, heightTextView);
    NSLog(@"Description view: %f %f", descriptionSize.height, descriptionSize.width);
    
    CGFloat alertViewHeight = PADDING;
    NSArray *sortedSubviews = [alertDialogView.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2) {
        if (obj1.tag > obj2.tag) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    for (UIView *subview in alertDialogView.subviews) {
        
        if (subview.hidden == NO) {
            subview.frame = CGRectMake(subview.frame.origin.x, alertViewHeight, CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame));
            alertViewHeight += CGRectGetHeight(subview.frame);
        }
    }
    
    alertDialogView.frame = CGRectMake(0, alertDialogView.frame.origin.y, 320, alertViewHeight);
}

-(void)remove {
    [self removeObservers];
    [UIView animateWithDuration:.2 animations:^{
        alertDialogView.frame = CGRectMake(0, self.frame.size.height, CGRectGetWidth(alertDialogView.frame), CGRectGetHeight(alertDialogView.frame));
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)leftButtonAction {
    
    if (self.leftButtonActionBlock != NULL) {
        self.leftButtonActionBlock(addedSubViews);
    }

    [self remove];
}

-(void)rightButtonAction {
    if (self.rightButtonActionBlock != NULL) {
        self.rightButtonActionBlock(addedSubViews);
    }
    
    [self remove];
}


-(void)showInView:(UIView *)theView {
    
    superView = theView;
    self.frame = CGRectMake(0, 0, CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame));
    [superView addSubview:self];
    
    [self configurePromptLabel];
    [self configureAlertDialog];
    [self addSubview:alertDialogView];
    [self configureLeftButton];
    [self configureRightButton];
    
    [self resizeAlertViewForText];
    [UIView animateWithDuration:.2 animations:^{
        
        CGFloat alertDialogY = superView.frame.size.height - alertDialogView.frame.size.height;
        alertDialogView.frame = CGRectMake(0, alertDialogY, alertDialogView.frame.size.width, alertDialogView.frame.size.height);
        NSLog(@"alert dialog frame: %@", CGRectCreateDictionaryRepresentation(alertDialogView.frame));
    }];
}

@end
