#import "Figure+FigureHelper.h"

@implementation Figure (FigureHelper)

#define kID @"id"
#define KImageURL @"image_url"
#define kName @"name"

+(Figure *)figureFromJSON:(NSDictionary *)JSONDict inContext:(NSManagedObjectContext *)context {
    NSString *figureID = JSONDict[kID];
    NSArray *existingFigure = [Figure objectsWithValue:figureID forKey:@"id" inContext:context];
    Figure *figure = nil;
    
    if ([existingFigure count] > 0) {
        figure = [existingFigure firstObject];
    } else {
        figure = [Figure newInContext:context];
        figure.id = JSONDict[kID];
        figure.imageURL = JSONDict[KImageURL];
        figure.name = JSONDict[kName];
    }
    
    return figure;
}

@end
