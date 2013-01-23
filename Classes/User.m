#import "User.h"

@implementation User

static NSString *KeyForFirstName = @"FirstName";
static NSString *KeyForLastName = @"LastName";
static NSString *KeyForFacebookId = @"FacebookId";
static NSString *KeyForBirthday = @"Birthday";


-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        self.firstName = [aDecoder decodeObjectForKey:KeyForFirstName];
        self.lastName = [aDecoder decodeObjectForKey:KeyForLastName];
        self.facebookId = [aDecoder decodeObjectForKey:KeyForFacebookId];
        self.birthday = [aDecoder decodeObjectForKey:KeyForBirthday];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.firstName forKey:KeyForFirstName];
    [aCoder encodeObject:self.lastName forKey:KeyForLastName];
    [aCoder encodeObject:self.facebookId forKey:KeyForFacebookId];
    [aCoder encodeObject:self.birthday forKey:KeyForBirthday];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ %@\nFB id: %@\nBirthday: %@", self.firstName, self.lastName, self.facebookId, self.birthday];
}

@end
