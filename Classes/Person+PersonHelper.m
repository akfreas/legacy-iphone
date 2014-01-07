#import "Person+PersonHelper.h"
#import "PersistenceManager.h"

@implementation Person (PersonHelper)

#define kBirthday @"birthday"
#define kFacebookID @"facebook_id"
#define kFirstName @"first_name"
#define kLastName @"last_name"
#define kProfilePic @"profile_pic"

+(Person *)primaryPersonInContext:(NSManagedObjectContext *)context {
    if (context == nil) {
        context = [[PersistenceManager sharedInstance] managedObjectContext];
    }
    NSFetchRequest *request = [self baseFetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"isPrimary == %@", [NSNumber numberWithBool:YES]];
    NSArray *retArr = [context executeFetchRequest:request];
    if ([retArr count] > 1) {
        [NSException raise:LegacyCoreDataException format:@"There exists not 1 primary user, but %d! Raising exception", [retArr count]];
    }
    
    return [retArr firstObject];
}

+(Person *)personWithFacebookGraphUser:(id<FBGraphUser>)graphUser inContext:(NSManagedObjectContext *)context {
    if (context == nil) {
        context = [[PersistenceManager sharedInstance] managedObjectContext];
    }
    
    Person *existingPerson = [self personWithFacebookID:graphUser.id context:context];
    if (existingPerson != nil) {
        return existingPerson;
    }
    
    Person *newPerson = [Person newInContext:context];
    newPerson.facebookId = graphUser.id;
    newPerson.firstName = graphUser.first_name;
    newPerson.lastName = graphUser.last_name;
    newPerson.birthday = [[Utility_AppSettings dateFormatterForDisplay] dateFromString:graphUser.birthday];
    newPerson.profilePicURL = graphUser[@"picture"][@"data"][@"url"];
    newPerson.isPrimary = [NSNumber numberWithBool:NO];
    newPerson.isFacebookUser = [NSNumber numberWithBool:YES];
    return newPerson;
}

+(NSArray *)allPersonsInContext:(NSManagedObjectContext *)context includePrimary:(BOOL)includePrimary {
    
    if (context == nil) {
        context = [[PersistenceManager sharedInstance] managedObjectContext];
    }
    
    NSFetchRequest *fetch = [self baseFetchRequest];
    if (includePrimary == NO) {
        fetch.predicate = [NSPredicate predicateWithFormat:@"isPrimary <> %@", [NSNumber numberWithBool:YES]];
    }
    NSError *err = nil;
    NSArray *arr = [context executeFetchRequest:fetch error:&err];
    if (err != nil) {
        NSLog(@"Error performing fetch request for %@. Error: %@", self, err);
    }
    return arr;
}

+(Person *)personWithFacebookID:(NSString *)facebookID context:(NSManagedObjectContext *)context {
    if (context == nil) {
        context = [[PersistenceManager sharedInstance] managedObjectContext];
    }
    NSFetchRequest *request = [self baseFetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookID];
    NSArray *result = [context executeFetchRequest:request error:NULL];
    if ([result count] > 1) {
        [NSException raise:LegacyCoreDataException format:@"More than one Facebook user exists with ID %@, which should not be the case.  Users: %@", facebookID, result];
    }
    return [result firstObject];
}

+(Person *)personWithJSON:(NSDictionary *)JSONDict context:(NSManagedObjectContext *)context {
    if (context == nil) {
        context = [[PersistenceManager sharedInstance] managedObjectContext];
    }
    Person *existingPerson = [self personWithFacebookID:JSONDict[kFacebookID] context:context];
    if (existingPerson != nil) {
        return existingPerson;
    }
    
    
    Person *newPerson = [Person newInContext:context];
    newPerson.facebookId = JSONDict[kFacebookID];
    newPerson.birthday = [[Utility_AppSettings dateFormatterForDisplay] dateFromString:JSONDict[kBirthday]];
    newPerson.firstName = JSONDict[kFirstName];
    newPerson.lastName = JSONDict[kLastName];
    newPerson.isPrimary = [NSNumber numberWithBool:NO]; //TODO:This might mess up whatever primary user there is if it's not already set.
    newPerson.profilePicURL = JSONDict[kProfilePic];
    return newPerson;
}


-(NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

-(UIImage *)thumbnailImage {
    return [UIImage imageWithData:self.thumbnail];
}




@end
