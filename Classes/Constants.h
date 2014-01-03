#pragma mark NSNotification Keys

#define KeyForNoBirthdayNotification @"NoBirthdayForPerson"
#define KeyForPersonInBirthdayNotFoundNotification @"thePerson"
#define KeyForWikipediaButtonTappedNotification @"WikipediaButtonTapped"
#define KeyForRemovePersonButtonTappedNotification @"RemoveFriendButton"
#define KeyForOverlayViewShown @"OverlayViewShown"

#define KeyForFigureRowContentChanged @"FigureRowContentChanged"
#define KeyForFacebookButtonTapped @"FacebookButtonTapped"
#define KeyForInfoOverlayButtonTapped @"OverlayInfoButtonTapped"
#define KeyForAddFriendButtonTapped @"AddFriendButtonTapped"
#define KeyForPersonThumbnailUpdated @"PersonThumbnailUpdated"
#define KeyForUserHasAuthenticatedWithFacebook @"HasAuthenticatedWithFacebook"
#define KeyForHasBeenShownSwipeMessage @"HasShownSwipeMessage"
#define KeyForLastDateSynced @"LastDaySynced"
#define TableViewCellIdentifierForHeader @"HeaderCellIdentifier"
#define TableViewCellIdentifierForMainCell @"MainTableViewCell"
#define NoEventErrorKey @"NoEventError"
#define KeyForLoggedIntoFacebookNotification @"LoggedIntoFacebookNotification"
#define KeyForFigureRowTransportNotification @"FigureRowIncoming"
#define KeyForScrollToPageNotification @"ScrollToPageNotification"
#define KeyForPageNumberInUserInfo @"PageNumber"
#define KeyForPageTypeInUserInfo @"PageType"
#define KeyForHasScrolledToPageNotification @"HasScrolledToPage"
#define KeyForScrollingFromPageNotification @"ScrollingFromPage"

#define LegacyCoreDataException @"LegacyCoreDataException"

#pragma mark Size/Spacing Definitions

#define FigureRowCellHeight 75
#define NoEventFigureRowHeight 60
#define FigureRowCellWidth 320

#define SpaceBetweenFigureRowPages 0

#define FigureRowScrollViewPadding 1

#define PageControlYPosition 10
#define PageControlXPosition 240
#define PageControlWidthPerPage 20
#define PageControlHeight 20
#define PageControlCornerRadius 10.0

#define RelatedEventsLabelTopMargin 0
#define ImageLayerDefaultStrokeWidth 0

#define RelatedEventsLabelHeight 85
#define RelatedEventsLabelWidth 300

#define EventInfoHeaderCellHeight 200


#define MoreCloseButtonHeight 20
#define MoreCloseButtonWidth 100
#define MoreCloseButtonCornerRadius 7.0

#define LargeImageWidgetExpandedRadius 40

#define ImageWidgetInitialHeight 50
#define ImageWidgetInitialWidth 50
#define ImageWidgetExpandTransformFactor 2

#define RightIndicatorLinesFrameWidth 200
#define RightIndicatorLinesFrameHeight 400

#define TopActionViewHeight_OS7 64
#define TopActionViewHeight_non_OS7 64

#define FigureRowNameContainerViewHeight 40

#define OverlayViewButtonRadius 25

#define DrawerWidth 90.0f
#define PersonPhotoBorderWidth 2

#define TopBarButtonRadius 11
#define TopBarLeftMargin 15
#define TopBarTopMargin 15
#define DefaultFullscreenContentSize CGSizeMake(320, 480)

#define LegacyEntryHeight 170
#define FigurePhotoRadius 25
#define PersonPhotoRadius 14
#define PersonPhotoBorderSize 2
#define PersonPhotoOffset -5
#define EventHeaderCellLineStrokeWidth 1.0f

#pragma mark Color Definitions

#define TopActionViewDefaultTintColor [UIColor colorWithWhite:1 alpha:.85]
#define HeaderBackgroundColor [UIColor colorWithHexString:@"#3E94E0"]
#define AppLightBlueColor HeaderBackgroundColor
#define LightButtonColor [UIColor colorWithHexString:@"#9BC9ED"]
#define DarkButtonColor [UIColor colorWithHexString:@"#69AEE4"]
#define AgeLabelFontColor [UIColor colorWithHexString:@"#9B9B9B"]
#define LineSeparatorColor [UIColor colorWithHexString:@"#E1E4E6"]
#define TitleColor [UIColor colorWithHexString:@"#000000"]
#define FacebookModalDescriptionTextColor [UIColor colorWithHexString:@"#FFFFFF"]
#define PersonPhotoBorderColor [UIColor colorWithHexString:@"#FFFFFF"]
#define HeaderTextColor [UIColor whiteColor]

#pragma mark Font Definitions

#define FigureNameFontName @"HelveticaNeue"
#define FigureNameFontSize 22
#define FigureNameFont [UIFont fontWithName:FigureNameFontName size:FigureNameFontSize]
#define AgeLabelFontName @"HelveticaNeue-Light"
#define AgeLabelFontSize 12
#define AgeLabelFont [UIFont fontWithName:AgeLabelFontName size:AgeLabelFontSize]
#define SubtitleFontColor [UIColor colorWithHexString:@"#000000"]
#define SubtitleFontName @"HelveticaNeue-Light"
#define SubtitleFontSize 14
#define SubtitleFont [UIFont fontWithName:SubtitleFontName size:SubtitleFontSize]
#define HeaderFontName @"HelveticaNeue-Bold"
#define HeaderFontSize 25
#define HeaderFont [UIFont fontWithName:HeaderFontName size:HeaderFontSize]
#define LegacyPointSummaryFont [UIFont fontWithName:@"HelveticaNeue" size:15]
#define FacebookModalDescriptionFont [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]

#pragma mark Image Definitions

#define BackPageButtonImage [UIImage imageNamed:@"back-arrow.png"]
#define ForwardPageButtonImage [UIImage imageNamed:@"next-arrow.png"]
#define FacebookButtonImage [UIImage imageNamed:@"facebook-icon.png"]
#define TwitterButtonImage [UIImage imageNamed:@"twitter-icon.png"]
#define AddFriendsButtonImage [UIImage imageNamed:@"add-friends.png"]
#define CheckMarkImage [UIImage imageNamed:@"check-mark.png"]
#define NoEventImage [UIImage imageNamed:@"no-photo-legacy.png"]

#pragma mark Page Constants

#define MainEventPageNumber [NSNumber numberWithInteger:0]
#define FigureLegacyTimelineViewPageNumber [NSNumber numberWithInteger:1]
#define WikipediaViewPageNumber [NSNumber numberWithInteger:2]

#pragma mark Animation Durations

#define FacebookModalPresentationDuration 0.5f

#pragma mark Helpers

#define UIBind(...)  NSDictionary *BBindings = MXDictionaryOfVariableBindings(__VA_ARGS__)
#define AKNOTIF [NSNotificationCenter defaultCenter]
#define DEG2RAD(DEG) ((DEG)*((M_PI)/(180.0)))