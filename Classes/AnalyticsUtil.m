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
    
    NSString *label = [NSString stringWithFormat:@"transition_to_page_%@", [NSNumber numberWithInteger:to]];
    [ourTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"page_transition" label:label value:[NSNumber numberWithInteger:1]] build]];
}

+(void)logPressFromButton:(UIButton *)button {
    [ourTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"button_tapped" label:button.titleLabel.text value:[NSNumber numberWithInteger:1]] build ]];
}

+(void)logRelationTapped:(EventPersonRelation *)relation {
    NSString *label = [NSString stringWithFormat:@"event_id_%@", relation.event.eventId];
    [ourTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"relation_tapped" label:label value:[NSNumber numberWithInteger:1]] build]];
}

+(void)logConnectedToFacebook {
    [ourTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"connected_to_facebook" label:nil value:[NSNumber numberWithBool:YES]] build]];
}

+(void)logRelationShared:(EventPersonRelation *)relation network:(NSString *)network {
    [ourTracker send:[[GAIDictionaryBuilder createSocialWithNetwork:network action:@"share" target:[relation.event.eventId stringValue]] build]];
}

@end
