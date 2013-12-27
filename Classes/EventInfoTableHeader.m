#import "EventInfoTableHeader.h"
#import "EventPersonRelation.h"

@interface HeaderContentView : UIView

@end

@implementation HeaderContentView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}


-(BOOL)translatesAutoresizingMaskIntoConstraints {
    return NO;
}

@end

@implementation EventInfoTableHeader {
    
    UILabel *nameLabel;
    NSMutableArray *constraints;
    
    UIButton *leftButton;
    UIButton *rightButton;
    HeaderContentView *cv;
}

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.backgroundColor = HeaderBackgroundColor;
    }
    return self;
}

-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    [self addNameLabel];
}

-(void)layoutSubviews {
    
    if (leftButton == nil && rightButton == nil) {
        [self addButtons];
    }

    if (nameLabel != nil) {
        if ([constraints count] > 0) {
            [self.contentView removeConstraints:constraints];
        }
        UIBind(nameLabel);
        constraints = [NSMutableArray arrayWithArray:[self.contentView addConstraintWithVisualFormat:@"H:|-70-[nameLabel]" bindings:BBindings]];
        [constraints addObjectsFromArray:[self.contentView addConstraintWithVisualFormat:@"V:|-20-[nameLabel]-|" bindings:BBindings]];
        [nameLabel autoCenterInSuperview];
    }
    [super layoutSubviews];

}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(320, 64);
}

-(void)addNameLabel {
    nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.text = _relation.event.figure.name;
    nameLabel.font = HeaderFont;
    nameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:nameLabel];
}

-(void)addButtons {
    leftButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [leftButton setImage:[UIImage imageNamed:@"back-arrow"] forState:UIControlStateNormal];
    [self.contentView addSubview:leftButton];
    [leftButton bk_addEventHandler:^(id sender) {
        [AKNOTIF postNotificationName:KeyForScrollToPageNotification object:@{KeyForPageNumberInUserInfo : [NSNumber numberWithInteger:0]}];
    } forControlEvents:UIControlEventTouchUpInside];
    UIBind(leftButton);
    [self.contentView addConstraintWithVisualFormat:@"H:|-7-[leftButton]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|-24-[leftButton]" bindings:BBindings];
}

@end
