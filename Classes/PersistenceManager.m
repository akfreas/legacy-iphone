#import "PersistenceManager.h"

@implementation PersistenceManager {
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

static NSManagedObjectContext *parentContext;


-(id)initShared {
    self = [super init];
    if (self) {
        [PersistenceManager setupParentContext];
    }
    return self;
}

-(void)mergeChanges:(NSNotification *)notif {
    
    if ([NSThread isMainThread] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self mergeChanges:notif];
        });
        return;
    }
    [[PersistenceManager managedObjectContext] mergeChangesFromContextDidSaveNotification:notif];
}

+(instancetype)sharedInstance {
    static PersistenceManager *sharedInstance;
    if (sharedInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[self alloc] initShared];
            [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:nil];
        });
    }
    return sharedInstance;
}

+(void)setupPersistence {
    [[self sharedInstance] setupPersistence];
}

+(NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *ctx = [[self sharedInstance] managedObjectContext];
    NSLog(@"Context: %@", ctx);
    return ctx;
}

+(NSManagedObjectContext *)parentContext {
    @synchronized (self) {
        NSAssert(parentContext != nil, @"Parent context is nil!");
        NSLog(@"Parent context: %@", parentContext);
        return parentContext;
    }
}

+(void)setupParentContext {
    if (parentContext == nil) {
        parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        parentContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    }
}

+(NSManagedObjectContext *)managedObjectContextForUI {
    return [[self sharedInstance] managedObjectContextForUI];
}

+(void)deletePersistentStore {
    [[self sharedInstance] deletePersistentStore];
}

+(void)resetManagedObjectContext {
    [[self sharedInstance] resetManagedObjectContext];
}

+(void)save {
    [self saveContext:[PersistenceManager managedObjectContext]];
}

+(void)saveContext:(NSManagedObjectContext *)context {
    [[self sharedInstance] saveContext:context];
}

+(void)deleteObject:(NSManagedObject *)object {
    [[self sharedInstance] deleteObject:object];
}

+(void)deleteAllObjects {
    [[self sharedInstance] deleteAllObjectsAndSave];
}

-(void)deleteObjectsOfType:(__unsafe_unretained Class)class context:(NSManagedObjectContext *)context {
    if (context == nil) {
        context = [self managedObjectContext];
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(class)];
    NSError *err = nil;
    NSArray *allObjectsOfType = [context executeFetchRequest:request error:&err];
    if (err != nil) {
        NSLog(@"Error deleting all objects of type %@. Error: %@", class, err);
    }
    for (NSManagedObject *obj in allObjectsOfType) {
        [obj.managedObjectContext deleteObject:obj];
    }
}


-(void)setupPersistence {
    [self managedObjectContext];
}

#pragma mark Boilerplate CoreData

+(NSManagedObjectModel *)managedObjectModel {
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:nil];
    return mom;
}

+(NSURL *)persistentStoreURL {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSURL *url = [NSURL fileURLWithPath:[basePath stringByAppendingPathComponent:@"LegacyModel"]];
    return url;
}

+(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    static NSPersistentStoreCoordinator *staticCoordinator;
    if (staticCoordinator == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSError *error;
            NSURL *dbPath = [self persistentStoreURL];
            staticCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
            [staticCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbPath options:nil error:&error];
            if (error != nil) {
                [NSException raise:LegacyCoreDataException format:@"Error loading persistent store coordinator: %@", error];
            }
        });
    }
    return staticCoordinator;
}

-(NSManagedObjectContext *)managedObjectContext {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    NSManagedObjectContext *threadMOC = [threadDict objectForKey:@"ThreadMOC"];
    if (threadMOC == nil) {
        threadMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        threadMOC.parentContext = [PersistenceManager parentContext];
        [threadDict setObject:threadMOC forKey:@"ThreadMOC"];
    } else {
        NSLog(@"Got thread context. Thread: %@", [NSThread currentThread]);
    }
    return threadMOC;
}

-(NSManagedObjectContext *)managedObjectContextForUI {
    if (_managedObjectContext == nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = [PersistenceManager persistentStoreCoordinator];
    }
    return _managedObjectContext;
}

-(void)saveContext:(NSManagedObjectContext *)context {
    NSError *error;
    if (context.hasChanges == YES) {
        [context save:&error];
        if (context.parentContext != nil) {
            [context.parentContext save:&error];
        }
    }
    
    if (error != nil) {
        NSLog(@"Error saving into managedObjectContext. Message: %@", error.description);
    }
}

-(void)save {
    NSError *saveError = nil;
    BOOL saved = NO;
    NSManagedObjectContext *moc = [PersistenceManager managedObjectContext];
    if ([moc hasChanges]) {
        saved = [moc save:&saveError];
        if (moc.parentContext != nil) {
            [moc.parentContext save:&saveError];
        }
    }
    if (saved == NO) {
        NSLog(@"Context %@ was not saved.", [PersistenceManager managedObjectContext]);
    }
    if (saveError != nil) {
        [NSException raise:LegacyCoreDataException format:@"Error saving context %@. Error: %@", [PersistenceManager managedObjectContext], saveError];
    }
}

-(void)resetManagedObjectContext {
    self.managedObjectContext = nil;
}

-(void)deletePersistentStore {
    NSURL *persistentStoreURL = [PersistenceManager persistentStoreURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:persistentStoreURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:persistentStoreURL error:NULL];
    }
    persistentStoreCoordinator = nil;
    [self resetManagedObjectContext];
}

-(void)deleteObject:(NSManagedObject *)object {
    [object.managedObjectContext deleteObject:object];
}

-(void)deleteAllObjectsAndSave {
    [self deleteAllObjectsInContext:self.managedObjectContext];
}

-(void)deleteAllObjectsInContext:(NSManagedObjectContext *)context {
    NSManagedObjectModel *mom = [PersistenceManager managedObjectModel];
    NSError *error;
    NSArray *objArray;
    for (NSEntityDescription *entityDesc in mom) {
        NSEntityDescription *ourDesc = [NSEntityDescription entityForName:entityDesc.name inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *fetch = [NSFetchRequest new];
        fetch.entity = ourDesc;
        objArray = [context executeFetchRequest:fetch error:&error];
        if (objArray != nil) {
            if (error != nil || [objArray respondsToSelector:@selector(count)] == NO) {
                NSLog(@"Error fetching instances of %@ from core data.", entityDesc.name);
                return;
            }
            for (NSManagedObject *obj in objArray) {
                [self.managedObjectContext deleteObject:obj];
            }
        }
    }
    [self save];
    if (error != nil) {
        NSLog(@"Error deleting all instances of %@ from core data.",  mom.entities);
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
