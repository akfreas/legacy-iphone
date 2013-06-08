#import "PersonRowPageProtocol.h"

@class Figure;
@interface DescriptionPage : UIView <PersonRowPageProtocol>

- (id)initWithFigure:(Figure *)theFigure;

@property (strong, nonatomic) IBOutlet UIView *view;

@end
