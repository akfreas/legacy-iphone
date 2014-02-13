//
//  Figure.m
//  LegacyApp
//
//  Created by Alexander Freas on 1/8/14.
//
//

#import "Figure.h"
#import "Event.h"


@implementation Figure

@dynamic id;
@dynamic imageData;
@dynamic imageURL;
@dynamic name;
@dynamic eventsSynced;
@dynamic associatedEvents;
@dynamic events;

-(UIImage *)image {
    return [UIImage imageWithData:self.imageData];
}

@end
