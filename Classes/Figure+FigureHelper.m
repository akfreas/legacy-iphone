#import "Figure+FigureHelper.h"

@implementation Figure (FigureHelper)

#define kID @"id"
#define KImageURL @"image_url"
#define kName @"name"
#define kNumberAssociatedEvents @"events_count"

+(Figure *)figureFromJSON:(NSDictionary *)JSONDict inContext:(NSManagedObjectContext *)context {
    NSString *figureID = JSONDict[kID];
    NSArray *existingFigure = [Figure MR_findByAttribute:@"id" withValue:figureID inContext:context];
    Figure *figure = nil;
    
    if ([existingFigure count] > 0) {
        figure = [existingFigure firstObject];
    } else {
        figure = [Figure MR_createInContext:context];
        figure.associatedEvents = [NSNumber numberWithInteger:[JSONDict[kNumberAssociatedEvents] integerValue]];
        figure.eventsSynced = [NSNumber numberWithBool:NO];
        figure.id = JSONDict[kID];
        figure.imageURL = JSONDict[KImageURL];
        figure.name = JSONDict[kName];
    }
    
    return figure;
}

@end
