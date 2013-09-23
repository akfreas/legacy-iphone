//
//  Person.h
//  Legacy
//
//  Created by Alexander Freas on 6/19/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * isFacebookUser;
@property (nonatomic, retain) NSNumber * isPrimary;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSData * thumbnail;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

-(NSString *)fullName;

@end
