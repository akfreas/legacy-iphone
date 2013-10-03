//
//  EventPersonRelation.h
//  LegacyApp
//
//  Created by Alexander Freas on 10/2/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Person;

@interface EventPersonRelation : NSManagedObject

@property (nonatomic, retain) NSNumber * pinsToTop;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Person *person;

@end
