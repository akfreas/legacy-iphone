#import "EventRowContentView.h"
#import "ImageWidgetContainer.h"
#import "Person.h"
#import "Event.h"
#import "EventPersonRelation.h"
#import "Figure.h"
#import "LegacyAppConnection.h"
#import "LegacyAppRequest.h"
#import "RelatedEventLabel.h"
#import "ImageWidget.h"
#import "Utility_AppSettings.h"

@implementation EventRowContentView {
    
    UILabel *eventSubtitleLabel;
    UILabel *figureNameLabel;
    UILabel *ageLabel;
    UIView *arrowView;

    UITapGestureRecognizer *tapGesture;
}

-(id)initForAutoLayout {
    self = [super initForAutoLayout];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addUIComponents];
        [self addTapGesture];
    }
    return self;
}


-(void)addArrowView {
    if (arrowView == nil) {
        arrowView = [[UIView alloc] initWithFrame:CGRectZero];
        arrowView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next-arrow-gray"]];
        arrowImage.translatesAutoresizingMaskIntoConstraints = NO;
        [arrowView addSubview:arrowImage];
        [arrowView addConstraint:[NSLayoutConstraint constraintWithItem:arrowImage
                                                              attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:arrowView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [arrowView addConstraint:[NSLayoutConstraint constraintWithItem:arrowImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:arrowView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        
        [self addSubview:arrowView];
    }
}


-(CGSize)intrinsicContentSize {
    return CGSizeMake(FigureRowCellWidth, FigureRowCellHeight);
}


-(void)addTapGesture {
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendTapNotification)];
    [self addGestureRecognizer:tapGesture];
}

-(void)addUIComponents {
    [self addEventDescriptionLabel];
    [self addFigureNameLabel];
    [self addAgeLabel];
    [self addWidgetContainer];
    [self addArrowView];
    [self setConstraints];
    [self layoutIfNeeded];
}

-(void)setConstraints {
    UIBind(eventSubtitleLabel, figureNameLabel, ageLabel, _widgetContainer, arrowView);
    [self addConstraintWithVisualFormat:@"H:|-77-[figureNameLabel]-|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"H:|-77-[eventSubtitleLabel(200)]-(>=8)-|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"H:|-77-[ageLabel]-(>=8)-|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:|-(>=2)-[figureNameLabel]-(2)-[ageLabel]-(>=2)-[eventSubtitleLabel]-(>=5)-|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"H:|-(>=9)-[_widgetContainer(55)]-(>=8)-[figureNameLabel]" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:|-(>=10)-[_widgetContainer(55)]-(>=10)-|" bindings:BBindings];
    
    [arrowView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self];
    [self addConstraintWithVisualFormat:@"H:[arrowView(25)]-|" bindings:BBindings];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_widgetContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

-(void)addEventDescriptionLabel {
    eventSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    eventSubtitleLabel.font = SubtitleFont;
    eventSubtitleLabel.textColor = SubtitleFontColor;
    [self addSubview:eventSubtitleLabel];
}

-(void)addFigureNameLabel {
    figureNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    figureNameLabel.font = FigureNameFont;
    [self addSubview:figureNameLabel];
}

-(void)addAgeLabel {
    ageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    ageLabel.font = AgeLabelFont;
    ageLabel.textColor = AgeLabelFontColor;
    [self addSubview:ageLabel];
}

-(void)configureViewForNilEvent {
    arrowView.hidden = YES;
    figureNameLabel.text = @"Another Day";
    ageLabel.text = @"Another Time";
    eventSubtitleLabel.text = [NSString stringWithFormat:@"%@ has no matching Legacy today.", _relation.person.firstName];
    eventSubtitleLabel.adjustsFontSizeToFitWidth = YES;
    tapGesture.enabled = NO;
}

-(void)configureViewForNonNilEvent {
    
    tapGesture.enabled = YES;
    figureNameLabel.text = _relation.event.figure.name;
    eventSubtitleLabel.text = _relation.event.eventDescription;
    eventSubtitleLabel.adjustsFontSizeToFitWidth = NO;
    ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", _relation.event.ageYears, _relation.event.ageMonths, _relation.event.ageDays];
    arrowView.hidden = NO;
}

-(void)addWidgetContainer {
    _widgetContainer = [[ImageWidgetContainer alloc] init];
    [self addSubview:_widgetContainer];
}

-(void)sendTapNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:EventRowTappedNotificationKey object:self userInfo:@{@"relation" : self.relation}];
}

-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    self.widgetContainer.relation = _relation;
    if (_relation.event == nil) {
        [self configureViewForNilEvent];
    } else {
        [self configureViewForNonNilEvent];
    }
}
@end
