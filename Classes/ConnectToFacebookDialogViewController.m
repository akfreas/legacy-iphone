#import "ConnectToFacebookDialogViewController.h"
#import "ConnectToFacebookDialogView.h"

@interface ConnectToFacebookDialogViewController ()

@end

@implementation ConnectToFacebookDialogViewController

-(id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)loadView {
    self.view = [[ConnectToFacebookDialogView alloc] initForAutoLayout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
