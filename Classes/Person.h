//
//  Person.h
//  LegacyApp
//
//  Created by Alexander Freas on 1/3/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventPersonRelation;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * isFacebookUser;
@property (nonatomic, retain) NSNumber * isPrimary;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * profilePicURL;
@property (nonatomic, retain) EventPersonRelation *eventRelation;
@property (nonatomic, readonly) UIImage *thumbnailImage;

@end
