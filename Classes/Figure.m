//
//  Figure.m
//  LegacyApp
//
//  Created by Alexander Freas on 8/29/13.
//
//

#import "Figure.h"
#import "Event.h"


@implementation Figure

@dynamic id;
@dynamic imageURL;
@dynamic name;
@dynamic imageData;
@dynamic events;


-(UIImage *)image {
    return [UIImage imageWithData:self.imageData];
}

@end
