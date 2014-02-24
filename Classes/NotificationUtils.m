#import "NotificationUtils.h"

@implementation NotificationUtils

+(void)scrollToPage:(PageNumber)page {
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForScrollToPageNotification object:nil userInfo:@{KeyForPageNumberInUserInfo: [NSNumber numberWithInteger:page]}];
}

+(void)dismissTourScreen {
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForTourCompletedNotification object:nil];
}

@end
