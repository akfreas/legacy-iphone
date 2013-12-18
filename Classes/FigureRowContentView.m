#import "FigureRowContentView.h"
#import "ImageWidgetContainer.h"
#import "Person.h"
#import "Event.h"
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
}


+ (Class)layerClass {
    return [CAGradientLayer class];
}


-(CGSize)intrinsicContentSize {
    return CGSizeMake(FigureRowCellWidth, FigureRowCellHeight);
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollEnabled = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addUIComponents];
    }
    return self;
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
    [self addConstraintWithVisualFormat:@"H:|-77-[figureNameLabel]-|" bindings:UIBindings];
    [self addConstraintWithVisualFormat:@"H:|-77-[eventSubtitleLabel]-10-|" bindings:UIBindings];
    [self addConstraintWithVisualFormat:@"H:|-77-[ageLabel]-|" bindings:UIBindings];
    [self addConstraintWithVisualFormat:@"V:|-(2)-[figureNameLabel]-(2)-[ageLabel]-(2)-[eventSubtitleLabel]-|" bindings:UIBindings];
    _widgetContainer.backgroundColor = [UIColor redColor];
    [self addConstraintWithVisualFormat:@"H:|-(10)-[_widgetContainer(40)]" bindings:UIBindings];
    [self addConstraintWithVisualFormat:@"V:|-[_widgetContainer]-|" bindings:UIBindings];
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

-(void)setEvent:(Event *)event {
    _event = event;
    figureNameLabel.text = event.figure.name;
    self.widgetContainer.event = event;
    eventSubtitleLabel.text = event.eventDescription;
    ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", event.ageYears, event.ageMonths, event.ageDays];
}
-(void)setPerson:(Person *)person {
    _person = person;
    self.widgetContainer.person = person;
}
@end
