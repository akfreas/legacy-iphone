#import "FigureRowPageProtocol.h"

@class Figure;
@interface DescriptionPage : UIView <FigureRowPageProtocol>

- (id)initWithFigure:(Figure *)theFigure;

@property (strong, nonatomic) IBOutlet UIView *view;

@end
