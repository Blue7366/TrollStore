#import "TSRootViewController.h"
#import "TSAppTableViewController.h"
#import "TSSettingsListController.h"
#import "TSAppDelegate.h"
#import <TSPresentationDelegate.h>

@implementation TSRootViewController

- (void)loadView {
	[super loadView];

	TSAppTableViewController* appTableVC = [[TSAppTableViewController alloc] init];
	appTableVC.title = @"Apps";

	TSSettingsListController* settingsListVC = [[TSSettingsListController alloc] init];
	settingsListVC.title = @"Settings";

	UINavigationController* appNavigationController = [[UINavigationController alloc] initWithRootViewController:appTableVC];
	UINavigationController* settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsListVC];
	
	appNavigationController.tabBarItem.image = [UIImage systemImageNamed:@"square.stack.3d.up.fill"];
	settingsNavigationController.tabBarItem.image = [UIImage systemImageNamed:@"gear"];

	self.title = @"TrollStore v2";
	self.viewControllers = @[appNavigationController, settingsNavigationController];
    
    // Add jailbreak UI elements
    [self setupJailbreakUI];
}

- (void)setupJailbreakUI {
    // Create status label
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 30)];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.statusLabel];
    
    // Create jailbreak button
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.frame = CGRectMake(20, 150, self.view.bounds.size.width - 40, 50);
    [self.jailbreakButton addTarget:self action:@selector(toggleJailbreak) forControlEvents:UIControlEventTouchUpInside];
    self.jailbreakButton.backgroundColor = [UIColor systemBlueColor];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.jailbreakButton.layer.cornerRadius = 10;
    [self.view addSubview:self.jailbreakButton];
    
    // Update initial status
    [self updateJailbreakStatus];
}

- (void)updateJailbreakStatus {
    TSAppDelegate *appDelegate = (TSAppDelegate *)[UIApplication sharedApplication].delegate;
    BOOL isActive = [appDelegate isJailbreakActive];
    
    self.statusLabel.text = isActive ? @"Jailbreak Status: Active" : @"Jailbreak Status: Inactive";
    [self.jailbreakButton setTitle:isActive ? @"Disable Jailbreak" : @"Enable Jailbreak" forState:UIControlStateNormal];
    self.jailbreakButton.backgroundColor = isActive ? [UIColor systemRedColor] : [UIColor systemGreenColor];
}

- (void)toggleJailbreak {
    TSAppDelegate *appDelegate = (TSAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([appDelegate isJailbreakActive]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Disable Jailbreak"
                                                                     message:@"Are you sure you want to disable the jailbreak? This will remove all tweaks and modifications."
                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Disable" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [appDelegate disableJailbreak];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enable Jailbreak"
                                                                     message:@"This will enable full jailbreak features on your device. Continue?"
                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Enable" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [appDelegate enableJailbreak];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
	[super viewDidLoad];
	TSPresentationDelegate.presentationViewController = self;
}

@end
