//
//  Figure.h
//  LegacyApp
//
//  Created by Alexander Freas on 1/8/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Figure : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * eventsSynced;
@property (nonatomic, retain) NSNumber * associatedEvents;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, readonly) UIImage *image;
@end

@interface Figure (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
