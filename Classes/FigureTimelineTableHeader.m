#import "FigureTimelineTableHeader.h"
#import "EventPersonRelation.h"

@implementation FigureTimelineTableHeader {
    
    UILabel *nameLabel;
    NSMutableArray *constraints;
    
    UIButton *leftButton;
    UIButton *rightButton;
}

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = HeaderBackgroundColor;
    }
    return self;
}

-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    [self addNameLabel];
    [self addButtons];
    [self configureLayoutConstraints];
}

-(void)configureLayoutConstraints {

    UIBind(leftButton, rightButton, nameLabel);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[leftButton]-[nameLabel]-[rightButton]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:BBindings]];
    [self.contentView addConstraintWithVisualFormat:@"V:|-24-[leftButton]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|-24-[rightButton]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|-24-[nameLabel]" bindings:BBindings];
}

-(void)prepareForReuse {
    [self configureLayoutConstraints];
}

-(void)addNameLabel {
    nameLabel = [[UILabel alloc] initForAutoLayout];
    nameLabel.text = _relation.event.figure.name;
    nameLabel.font = HeaderFont;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.contentMode = UIViewContentModeScaleAspectFit;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:nameLabel];
}

-(void)addButtons {
    leftButton = [[UIButton alloc] initForAutoLayout];
    [leftButton setImage:[UIImage imageNamed:@"back-arrow"] forState:UIControlStateNormal];
    [self.contentView addSubview:leftButton];
    [leftButton bk_addEventHandler:^(id sender) {
        [NotificationUtils scrollToPage:LandingPageNumber];
    } forControlEvents:UIControlEventTouchUpInside];
    
    rightButton = [[UIButton alloc] initForAutoLayout];
    [rightButton setImage:[UIImage imageNamed:@"next-arrow"] forState:UIControlStateNormal];
    [self.contentView addSubview:rightButton];
    [rightButton bk_addEventHandler:^(id sender) {
        [NotificationUtils scrollToPage:WebViewPageNumber];
    } forControlEvents:UIControlEventTouchUpInside];
    
}

@end
