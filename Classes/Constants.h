#define KeyForNoBirthdayNotification @"NoBirthdayForPerson"
#define KeyForPersonInBirthdayNotFoundNotification @"thePerson"
#define KeyForWikipediaButtonTappedNotification @"WikipediaButtonTapped"
#define KeyForRemovePersonButtonTappedNotification @"RemoveFriendButton"
#define KeyForOverlayViewShown @"OverlayViewShown"

#define KeyForFigureRowContentChanged @"FigureRowContentChanged"
//#define KeyForRowDataUpdated @"RowsUpdated"
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
#define TopActionViewDefaultTintColor [UIColor colorWithWhite:1 alpha:.85]

#define FigureRowCellHeight 75
#define NoEventFigureRowHeight 60
#define FigureRowCellWidth 320

#define DEG2RAD(DEG) ((DEG)*((M_PI)/(180.0)))
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

#define DrawerWidth 50

#define TopBarButtonRadius 11
#define TopBarLeftMargin 15
#define TopBarTopMargin 15

#define HeaderBackgroundColor [UIColor colorWithHexString:@"#3E94E0"]
#define AgeLabelFontColor [UIColor colorWithHexString:@"#9B9B9B"]
#define LineSeparatorColor [UIColor colorWithHexString:@"#E1E4E6"]
#define TitleColor [UIColor colorWithHexString:@"#000000"]

#define PersonPhotoBorderColor [UIColor colorWithHexString:@"#FFFFFF"]
#define PersonPhotoBorderWidth 2

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

#define LegacyEntryHeight 170
#define FigurePhotoRadius 25
#define PersonPhotoRadius 14
#define PersonPhotoBorderSize 2
#define PersonPhotoOffset 10

#define EventHeaderCellLineStrokeWidth 1.0f

#define UIBind(...)  NSDictionary *BBindings = MXDictionaryOfVariableBindings(__VA_ARGS__)