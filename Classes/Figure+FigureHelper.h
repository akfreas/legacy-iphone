#import "Figure.h"

@interface Figure (FigureHelper)

+(Figure *)figureFromJSON:(NSDictionary *)JSONDict inContext:(NSManagedObjectContext *)context;

@end
