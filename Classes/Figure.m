#import "Figure.h"

@implementation Figure

static NSString *KeyForName = @"name";
static NSString *KeyForImageUrl = @"image_url";
static NSString *KeyForDateOfBirth = @"date_of_birth";
static NSString *KeyForDateOfDeath = @"date_of_death";
static NSString *KeyForDescription = @"description";


-(id)initWithJsonDictionary:(NSDictionary *)dict {
    
    if (self == [super init]) {
        
        _name = dict[KeyForName];
        _imageUrl = [NSURL URLWithString:dict[KeyForImageUrl]];
        _dateOfBirth = dict[KeyForDateOfBirth];
        _dateOfDeath = dict[KeyForDateOfDeath];
        _description = dict[KeyForDescription];
    }
    
    return self;
}

@end
