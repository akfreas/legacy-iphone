#import "MigrationUtil.h"
#import "Person.h"

@implementation MigrationUtil

+(void)performDataMigrationsForCurrentVersion {
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_contextForCurrentThread];
    [ctx performBlock:^{
        NSArray *allPersons = [Person allPersonsInContext:ctx includePrimary:YES];
        for (Person *person in allPersons) {
            if ([person.isPrimary isEqualToNumber:@YES] == NO) {
                person.isPrimary = @NO;
            }
        }
        [ctx MR_saveOnlySelfAndWait];
    }];
}

@end
