@class EventPersonRelation;
@class ImageWidget;
@interface ImageWidgetContainer : UIView

@property (strong, nonatomic) EventPersonRelation *relation;
@property (nonatomic) ImageWidget *widget;

-(id)initWithRelation:(EventPersonRelation *)relation;

@end
