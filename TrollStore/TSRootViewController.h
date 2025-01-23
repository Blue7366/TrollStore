#import <UIKit/UIKit.h>

@interface TSRootViewController : UITabBarController

@property (nonatomic, strong) UIButton *jailbreakButton;
@property (nonatomic, strong) UILabel *statusLabel;

- (void)updateJailbreakStatus;
- (void)toggleJailbreak;

@end
