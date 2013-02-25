//
//  Person.h
//  Yardstick
//
//  Created by Alexander Freas on 2/20/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * isPrimary;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSNumber * isFacebookUser;

@end
