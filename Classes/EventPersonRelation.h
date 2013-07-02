//
//  EventPersonRelation.h
//  Legacy
//
//  Created by Alexander Freas on 6/23/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Person;

@interface EventPersonRelation : NSManagedObject

@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Person *person;

@end
