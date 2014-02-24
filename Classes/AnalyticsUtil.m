#import "AnalyticsUtil.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@implementation AnalyticsUtil

static id<GAITracker> ourTracker;

+(void)initialize {
    ourTracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-48135664-2"];
    [super initialize];
}

+(void)logPageTransitionTo:(NSInteger)to {
    
    [ourTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"page_transition" label:nil value:[NSNumber numberWithInteger:to]] build]];
}

+(void)logPressFromButton:(UIButton *)button {
    [ourTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"button_tapped" label:button.titleLabel.text value:nil] build ]];
}

+(void)logRelationTapped:(EventPersonRelation *)relation {
    [ourTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"relation_tapped" label:nil value:relation.event.eventId] build]];
}

+(void)logConnectedToFacebook {
    [ourTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"connected_to_facebook" label:nil value:[NSNumber numberWithBool:YES]] build]];
}

+(void)logRelationShared:(EventPersonRelation *)relation network:(NSString *)network {
    [ourTracker send:[[GAIDictionaryBuilder createSocialWithNetwork:network action:@"share" target:[relation.event.eventId stringValue]] build]];
}

@end
