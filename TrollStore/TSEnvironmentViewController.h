#import <UIKit/UIKit.h>
#import "TSEnvironmentManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSEnvironmentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) TSEnvironmentManager *manager;

- (void)showEnvironmentDetails:(TSEnvironment *)environment;

@end

NS_ASSUME_NONNULL_END
