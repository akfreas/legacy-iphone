#import "Figure.h"

@interface Figure (FigureHelper)

+(Figure *)figureFromJSON:(NSDictionary *)JSONDict inContext:(NSManagedObjectContext *)context;
-(UIImage *)thumbnailImage;
@end
