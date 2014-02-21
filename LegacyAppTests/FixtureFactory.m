#import "FixtureFactory.h"

@implementation FixtureFactory

+(NSArray *)eventsFromFixture {
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"EventsFixture" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
}

@end
