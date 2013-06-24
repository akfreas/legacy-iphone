//
//  Event.h
//  AtYourAge
//
//  Created by Alexander Freas on 6/19/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Figure, Person;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSNumber * ageYears;
@property (nonatomic, retain) NSNumber * ageMonths;
@property (nonatomic, retain) NSNumber * ageDays;
@property (nonatomic, retain) NSNumber * eventId;
@property (nonatomic, retain) Figure *figure;

@end
