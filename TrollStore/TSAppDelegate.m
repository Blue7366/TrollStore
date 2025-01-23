#import "TSAppDelegate.h"
#import "TSRootViewController.h"
#import "TSUtil.h"

@implementation TSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Initialize root view controller
    TSRootViewController *rootViewController = [[TSRootViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    // Check jailbreak status
    self.jailbreakEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_jailbreak"];
    
	return YES;
}

- (void)enableJailbreak {
    self.jailbreakEnabled = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"enable_jailbreak"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Restart app to apply jailbreak
    [self restartApp];
}

- (void)disableJailbreak {
    self.jailbreakEnabled = NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"enable_jailbreak"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Restart app to disable jailbreak
    [self restartApp];
}

- (BOOL)isJailbreakActive {
    return [[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb"];
}

- (void)restartApp {
    UIApplication *app = [UIApplication sharedApplication];
    NSString *appBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    [app terminateWithSuccess];
    
    // Launch URL to reopen app
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", appBundleIdentifier]];
    [app openURL:url options:@{} completionHandler:nil];
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end
