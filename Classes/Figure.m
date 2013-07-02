//
//  Figure.m
//  Legacy
//
//  Created by Alexander Freas on 6/20/13.
//
//

#import "Figure.h"
#import "Event.h"


@implementation Figure

@dynamic imageURL;
@dynamic name;
@dynamic id;
@dynamic events;

static NSString *KeyForName = @"name";
static NSString *KeyForImageUrl = @"image_url";


-(id)initWithJsonDictionary:(NSDictionary *)dict {
    
    if (self == [super init]) {
        
        self.name = dict[KeyForName];
        self.imageURL = [NSURL URLWithString:dict[KeyForImageUrl]];
    }
    
    return self;
}


@end
