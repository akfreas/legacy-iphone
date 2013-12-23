#import "FigureRowContentView.h"
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

@implementation FigureRowContentView {
    
    UILabel *eventSubtitleLabel;
    UILabel *figureNameLabel;
    UILabel *ageLabel;
    UITapGestureRecognizer *tapGesture;
}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(FigureRowCellWidth, FigureRowCellHeight);
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.scrollEnabled = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addUIComponents];
        [self addTapGesture];
    }
    return self;
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
    [self setConstraints];
}

-(void)setConstraints {
    UIBind(eventSubtitleLabel, figureNameLabel, ageLabel, _widgetContainer);
    [self addConstraintWithVisualFormat:@"H:|-77-[figureNameLabel(250)]-|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"H:|-77-[eventSubtitleLabel(200)]" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"H:|-77-[ageLabel]-|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:|-(2)-[figureNameLabel]-(2)-[ageLabel]-(2)-[eventSubtitleLabel]-|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"H:|-[_widgetContainer]-[figureNameLabel]" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:|-(10)-[_widgetContainer]-|" bindings:BBindings];
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
    ageLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:.6];
    ageLabel.layer.cornerRadius = 10;
    [self addSubview:ageLabel];
}

-(void)addWidgetContainer {
    _widgetContainer = [[ImageWidgetContainer alloc] init];
    [self addSubview:_widgetContainer];
}

-(void)sendTapNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForInfoOverlayButtonTapped object:nil userInfo:@{@"relation" : self.relation}];
}

-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    self.widgetContainer.relation = _relation;

    figureNameLabel.text = _relation.event.figure.name;
    eventSubtitleLabel.text = _relation.event.eventDescription;
    ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", _relation.event.ageYears, _relation.event.ageMonths, _relation.event.ageDays];
}
@end
