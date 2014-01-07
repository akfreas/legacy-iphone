#import "NSManagedObjectContext+ManagedObjectContextHelper.h"

@implementation NSManagedObjectContext (ManagedObjectContextHelper)

-(void)save {
    NSError *err = nil;
    [self save:&err];
    if (err != nil) {
        NSLog(@"Error saving context %@. Error: %@", self, [err description]);
    }
    if (self.parentContext != nil) {
        [self.parentContext save:&err];
    }
}

-(NSArray *)executeFetchRequest:(NSFetchRequest *)request {
    NSError *err = nil;
    NSArray *returnArray = [self executeFetchRequest:request error:&err];
    if (err != nil) {
        NSLog(@"Error executing fetch request: %@. Error: %@.", request, err);
    }
    return returnArray;
}

@end
