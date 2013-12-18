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

#define FigureRowCellHeight 140
#define NoEventFigureRowHeight 60
#define FigureRowCellWidth 320


#define SpaceBetweenFigureRowPages 1

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

#define ImageWidgetInitialHeight 90
#define ImageWidgetInitialWidth 90
#define ImageWidgetExpandTransformFactor 2

#define RightIndicatorLinesFrameWidth 200
#define RightIndicatorLinesFrameHeight 400

#define TopActionViewHeight_OS7 64
#define TopActionViewHeight_non_OS7 64

#define FigureRowNameContainerViewHeight 40

#define OverlayViewButtonRadius 25


#define TopBarButtonRadius 11
#define TopBarLeftMargin 15
#define TopBarTopMargin 15

#define HeaderBackgroundColor @"3E94E0"
#define DateFontColor @"9B9B9B"
#define LineSeparatorColor @"E1E4E6"
#define TitleColor @"000000"
#define TextLine1FontColor @"000000"
#define PersonPhotoBorderColor @"FFFFFF"

#define TitleFontName @"HelveticaNeue-Light"
#define TitleFontSize 36

#define TitleFont [UIFont fontWithName:TitleFontName size:TitleFontSize]

#define DateFontName @"HelveticaNeue-Light"
#define DateFontSize 24

#define DateFont [UIFont fontWithName:DateFontName size:DateFontSize]

#define SubtitleFontName @"HelveticaNeue-Light"
#define SubtitleFontSize 24

#define SubtitleFont [UIFont fontWithName:SubtitleFontName size:SubtitleFontSize]

#define HeaderFontName @"HelveticaNeue-Bold"
#define HeaderFontSize 25

#define HeaderFont [UIFont fontWithName:HeaderFontName size:HeaderFontSize]

#define LegacyEntryHeight 150
#define PersonPhotoRadius 25
#define PersonPhotoBorderSize 4
#define PersonPhotoOffset 10

#define UIBind(...)  NSDictionary *UIBindings = MXDictionaryOfVariableBindings(__VA_ARGS__)