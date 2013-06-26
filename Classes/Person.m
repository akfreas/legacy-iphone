//
//  Person.m
//  AtYourAge
//
//  Created by Alexander Freas on 6/19/13.
//
//

#import "Person.h"
#import "Event.h"


@implementation Person

@dynamic birthday;
@dynamic facebookId;
@dynamic firstName;
@dynamic isFacebookUser;
@dynamic isPrimary;
@dynamic lastName;
@dynamic thumbnail;
@dynamic events;

-(NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
