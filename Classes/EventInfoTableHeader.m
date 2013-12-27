#import "EventInfoTableHeader.h"
#import "EventPersonRelation.h"

@implementation EventInfoTableHeader {
    
    UILabel *nameLabel;
    NSMutableArray *constraints;
    
    UIButton *leftButton;
    UIButton *rightButton;
}

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior) context:nil];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.backgroundColor = HeaderBackgroundColor;
    }
    return self;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"Change: %@, obj: %@", change, object);
}

-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    [self addNameLabel];
    [self addButtons];
    [self configureLayoutConstraints];
}

-(void)configureLayoutConstraints {

    UIBind(leftButton, rightButton, nameLabel);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=10@250)-[leftButton(25)]-(>=5@100)-[nameLabel(>=200@1000)]-(>=5)-[rightButton(==leftButton)]-(>=5@100)-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:BBindings]];
    [self.contentView addConstraintWithVisualFormat:@"V:|-24-[leftButton]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|-24-[rightButton]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|-24-[nameLabel]" bindings:BBindings];
}


//-(void)prepareForReuse {
//    
//    if (nameLabel != nil) {
////        if ([constraints count] > 0) {
////            [self.contentView removeConstraints:constraints];
////        }
//        UIBind(nameLabel);
////        constraints = [NSMutableArray arrayWithArray:[self.contentView addConstraintWithVisualFormat:@"H:|-20-[nameLabel]|" bindings:BBindings]];
////        [constraints addObjectsFromArray:[self.contentView addConstraintWithVisualFormat:@"V:|-20-[nameLabel]-|" bindings:BBindings]];
//        [nameLabel autoCenterInSuperview];
//    }
//
//}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(320, 64);
}

-(void)addNameLabel {
    nameLabel = [[UILabel alloc] initForAutoLayout];
    nameLabel.text = _relation.event.figure.name;
    nameLabel.font = HeaderFont;
    nameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:nameLabel];
}

-(void)addButtons {
    leftButton = [[UIButton alloc] initForAutoLayout];
    [leftButton setImage:[UIImage imageNamed:@"back-arrow"] forState:UIControlStateNormal];
    [self.contentView addSubview:leftButton];
    [leftButton bk_addEventHandler:^(id sender) {
        [AKNOTIF postNotificationName:KeyForScrollToPageNotification object:nil userInfo:@{KeyForPageNumberInUserInfo : [NSNumber numberWithInteger:0]}];
    } forControlEvents:UIControlEventTouchUpInside];
    
    rightButton = [[UIButton alloc] initForAutoLayout];
    [rightButton setImage:[UIImage imageNamed:@"next-arrow"] forState:UIControlStateNormal];
    [self.contentView addSubview:rightButton];
    [rightButton bk_addEventHandler:^(id sender) {
        [AKNOTIF postNotificationName:KeyForScrollToPageNotification object:nil userInfo:@{KeyForPageNumberInUserInfo: [NSNumber numberWithInteger:2]} ];
    } forControlEvents:UIControlEventTouchUpInside];
    
}

@end
