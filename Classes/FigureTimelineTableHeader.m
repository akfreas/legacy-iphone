#import "FigureTimelineTableHeader.h"
#import "EventPersonRelation.h"
#import "ButtonWithImageView.h"


@implementation FigureTimelineTableHeader {
    
    UILabel *nameLabel;
    NSMutableArray *constraints;
    
    ButtonWithImageView *leftButton;
    ButtonWithImageView *rightButton;
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
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:8]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:leftButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:rightButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftButton(>=70)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:BBindings]];
    [self.contentView addConstraintWithVisualFormat:@"H:[nameLabel(200)]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"H:[rightButton(>=70)]|" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"H:|[leftButton(>=70)]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|-(<=20)-[leftButton(>=40)]|" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|-(<=20)-[rightButton(>=40)]|" bindings:BBindings];
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
    leftButton = [[ButtonWithImageView alloc] initForAutoLayout];
    [leftButton configureForBackButton];
    [self.contentView addSubview:leftButton];
    [leftButton bk_addEventHandler:^(id sender) {
        [NotificationUtils scrollToPage:LandingPageNumber];
    } forControlEvents:UIControlEventTouchUpInside];
    
    rightButton = [[ButtonWithImageView alloc] initForAutoLayout];
    [rightButton configureForForwardButton];
    [self.contentView addSubview:rightButton];
    [rightButton bk_addEventHandler:^(id sender) {
        [NotificationUtils scrollToPage:WebViewPageNumber];
    } forControlEvents:UIControlEventTouchUpInside];
    
}

@end
