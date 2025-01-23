#import <UIKit/UIKit.h>

@interface TSAppEnvironmentController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, strong) NSMutableDictionary *environmentVariables;
@property (nonatomic, strong) UITableView *tableView;

- (instancetype)initWithBundleIdentifier:(NSString *)bundleIdentifier;
- (void)saveEnvironmentVariables;
- (void)loadEnvironmentVariables;
- (void)applyEnvironmentVariables;

@end
