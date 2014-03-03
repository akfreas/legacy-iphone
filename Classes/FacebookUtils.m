#import "FacebookUtils.h"
#import "DataSyncUtility.h"
#import "LegacyAppConnection.h"
#import "LegacyAppRequest.h"


@implementation FacebookUtils

+(void)getAndSavePrimaryUser:(void(^)())completion {
    FBRequest *request = [FBRequest requestForMe];
    [request.parameters setObject:@"first_name,last_name,birthday,picture" forKey:@"fields"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
        NSManagedObjectContext *ctx = [NSManagedObjectContext MR_contextForCurrentThread];
        [ctx performBlock:^{
            
            Person *primaryPerson = [Person personWithFacebookGraphUser:result inContext:ctx];
            primaryPerson.isPrimary = [NSNumber numberWithBool:YES];
            [ctx MR_saveOnlySelfAndWait];
            if (completion != NULL) {
                completion();
            }
            LegacyAppRequest *request = [LegacyAppRequest requestToGetEventForPerson:primaryPerson];
            [LegacyAppConnection get:request withCompletionBlock:^(LegacyAppRequest *request, NSDictionary *relation, NSError *error) {
                [ctx performBlock:^{
                    [EventPersonRelation relationFromJSON:relation context:ctx];
                    [[DataSyncUtility sharedInstance] sync:NULL];
                    [ctx MR_saveOnlySelfAndWait];
                }];
            }];
        }];
    }];
}

+(void)loginWithFacebook:(void(^)())completion {
    
    //    [[NSUserDefaults standardUserDefaults] setValue:@"CAABr4W3cfKwBAL3Us8sCZB7GCfJe0AyAuXjhhmNy5pFYeGfsuMs0QTgMjrDJpodahFQFIMt3PuTgrSD2zszYZAh0hBobYeJTEGZCb5v2elPrGmbRbgnTvNR2MLhS7sbp4NqdHmEoozYgQiazfiDj7nXndBeWCj13iHZBSfcgKQZDZD" forKey:@"FBAccessTokenInformationKey"];
    if ([[FBSession activeSession] isOpen] == NO) {
        if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
            [FBSession openActiveSessionWithAllowLoginUI:NO];
            if (completion != NULL) {
                completion();
            }
        } else {
            [FacebookUtils startFBLoginProcess:completion];
        }
    } else {
        if (completion != NULL) {
            completion();
        }
    }
}


+(void)startFBLoginProcess:(void(^)())completion {
    //
    //    NSDictionary *accessToken = @{
    //                                  @"com.facebook.sdk:TokenInformationExpirationDateKey" : [NSDate distantFuture],
    //                                  @"com.facebook.sdk:TokenInformationIsFacebookLoginKey" : [NSNumber numberWithInt:1],
    //                                  @"com.facebook.sdk:TokenInformationLoginTypeLoginKey" : [NSNumber numberWithInt:3],
    //                                  @"com.facebook.sdk:TokenInformationPermissionsKey" :     @[
    //                                          @"user_birthday",
    //                                          @"friends_birthday"
    //                                          ],
    //                                  @"com.facebook.sdk:TokenInformationRefreshDateKey" : [NSDate date],
    //                                  @"com.facebook.sdk:TokenInformationTokenKey" : @"CAABr4W3cfKwBABZBAVmuUjZCJPmR7ZAfhOmvAOozxmOUzAtHumi8ZBXI26fiHd8iPvTS6uUqZAmxNsaM17Qjfz5kDZBNoEJjlWXZBo4ISguulPuNHPCmTywq1De58Tww1hK1wZANAfTILnikQe8FIa7IBcXLRr4XDNihNha5NytppwZDZD"
    //                                  };
    //
    //    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"FBAccessTokenInformationKey"];
    FBSession *session = [[FBSession alloc] initWithPermissions:@[@"user_birthday", @"friends_birthday"]];
    [FBSession setActiveSession:session];
    
    [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (status == FBSessionStateOpen) {
            [FBSession setActiveSession:session];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForUserHasAuthenticatedWithFacebook];
            [FacebookUtils getAndSavePrimaryUser:completion];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KeyForUserHasAuthenticatedWithFacebook];
        }
    }];
}



@end
