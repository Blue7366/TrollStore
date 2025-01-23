#import <UIKit/UIKit.h>

@interface TSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL jailbreakEnabled;

- (void)enableJailbreak;
- (void)disableJailbreak;
- (BOOL)isJailbreakActive;

@end
