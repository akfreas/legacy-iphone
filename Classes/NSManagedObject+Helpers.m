#import "NSManagedObject+Helpers.h"


@implementation NSManagedObject (Helpers)




+(instancetype)new {
    id instance = [self newInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return instance;
}

+(instancetype)newInContext:(NSManagedObjectContext *)context {
    Class ourClass = self.class;
    id instance = [[ourClass alloc] initWithEntity:[self entityDescriptionInContext:context] insertIntoManagedObjectContext:context];
    return instance;
}

+(instancetype)objectWithObjectID:(NSManagedObjectID *)objectId {
    return [self objectWithObjectID:objectId inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+(instancetype)objectWithObjectID:(NSManagedObjectID *)objectId inContext:(NSManagedObjectContext *)context {
    id objectWithID = [context objectWithID:objectId];
    return objectWithID;
}

-(void)save {
    NSError *saveError = nil;
    if ([self.managedObjectContext hasChanges]) {
        [self.managedObjectContext save:&saveError];
    }
    if (saveError != nil) {
        NSLog(@"Error saving %@, error: %@", self, [saveError description]);
    }
}

-(void)delete {
    [self.managedObjectContext deleteObject:self];
}

-(void)saveInContext:(NSManagedObjectContext *)context {
    
    NSError *error = nil;
    if (context.hasChanges == YES) {
        [context save:&error];
    }
    if (error != nil) {
        NSLog(@"Error encountered while saving instance of %@. Description: %@", NSStringFromClass(self.class), error.description);
    }
}

+(NSArray *)objectsWithValue:(id)value forKey:(id)key inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [self baseFetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %@", value, key];
    fetchRequest.predicate = predicate;
    NSError *err = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&err];
    if (err != nil) {
        NSLog(@"Error fetching %@ == %@ for %@ object.  Error: %@", key, value, [self class], [err description]);
    }
    return results;
}

#pragma mark Inspired by http://www.cimgf.com/2011/03/13/super-happy-easy-fetching-in-core-data/

+(NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
        return entityDescription;
}


+(NSArray *)allObjectsInContext:(NSManagedObjectContext *)context {
    
    NSError *getterError = nil;
    NSString *entityName = NSStringFromClass(self.class);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [request setEntity:[self entityDescriptionInContext:context]];
    NSArray *objects = [context executeFetchRequest:request error:&getterError];
    if (getterError != nil) {
        NSLog(@"Error getting all objects for entity name %@. Description: %@", entityName, getterError.description);
    }
    return objects;
}

+(NSFetchRequest *)baseFetchRequest {
    return [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self.class)];
}

//-(NSString *)description {
//    NSMutableString *descriptionString = [NSMutableString new];
//    if (self.managedObjectContext != nil) {
//        NSEntityDescription *entityDescription = [self.class entityDescriptionInContext:self.managedObjectContext];
//        NSArray *instanceProperties = entityDescription.properties;
//        for (NSPropertyDescription *propertyDesc in instanceProperties) {
//            [descriptionString appendFormat:@"%@ = %@, ", propertyDesc.name, [self valueForKey:propertyDesc.name]];
//        }
//    } else {
//        [descriptionString appendString:NSStringFromClass(self.class)];
//    }
//    return descriptionString;
//}


@end
