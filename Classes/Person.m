//
//  Person.m
//  LegacyApp
//
//  Created by Alexander Freas on 1/3/14.
//
//

#import "Person.h"
#import "EventPersonRelation.h"


@implementation Person

@dynamic birthday;
@dynamic facebookId;
@dynamic firstName;
@dynamic isFacebookUser;
@dynamic isPrimary;
@dynamic lastName;
@dynamic thumbnail;
@dynamic profilePicURL;
@dynamic eventRelation;

-(UIImage *)thumbnailImage {
    return [UIImage imageWithData:self.thumbnail];
}

@end
