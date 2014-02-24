#import "TourScreenViewController.h"
#import "TourScreenScrollView.h"

@interface TourScreenViewController ()
@property TourScreenScrollView *tourScrollView;
@end

@implementation TourScreenViewController

-(id)init {
    self = [super init];
    if (self) {
        self.tourScrollView = [[TourScreenScrollView alloc] initForAutoLayout];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:KeyForTourCompletedNotification object:nil];
    }
    return self;
}

-(void)dismiss {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForHasBeenShownTour];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tourScrollView];
    NSDictionary *bindings = @{@"tourScrollView": self.tourScrollView};
    [self.view addConstraintWithVisualFormat:@"H:|[tourScrollView]|" bindings:bindings];
    [self.view addConstraintWithVisualFormat:@"V:|[tourScrollView]|" bindings:bindings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
