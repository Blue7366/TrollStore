#import "TSEnvironmentViewController.h"

@interface TSEnvironmentViewController ()
@property (nonatomic, strong) NSArray<TSEnvironment *> *filteredEnvironments;
@end

@implementation TSEnvironmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Environment Manager";
    self.manager = [TSEnvironmentManager sharedManager];
    
    [self setupUI];
    [self setupSearchController];
}

- (void)setupUI {
    // Setup table view
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Register cell class
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"EnvironmentCell"];
    
    [self.view addSubview:self.tableView];
    
    // Add apply button
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(applyChanges)];
    self.navigationItem.rightBarButtonItem = applyButton;
}

- (void)setupSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Search Environments";
    
    self.navigationItem.searchController = self.searchController;
    self.definesPresentationContext = YES;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        return [self.filteredEnvironments count];
    }
    return section == 0 ? [self.manager.privateEnvironments count] : [self.manager.publicEnvironments count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        return @"Search Results";
    }
    return section == 0 ? @"Private Environments" : @"Public Environments";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnvironmentCell" forIndexPath:indexPath];
    
    TSEnvironment *environment;
    if (self.searchController.isActive) {
        environment = self.filteredEnvironments[indexPath.row];
    } else {
        environment = indexPath.section == 0 ? 
            self.manager.privateEnvironments[indexPath.row] : 
            self.manager.publicEnvironments[indexPath.row];
    }
    
    cell.textLabel.text = environment.name;
    cell.detailTextLabel.text = environment.category;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TSEnvironment *environment;
    if (self.searchController.isActive) {
        environment = self.filteredEnvironments[indexPath.row];
    } else {
        environment = indexPath.section == 0 ? 
            self.manager.privateEnvironments[indexPath.row] : 
            self.manager.publicEnvironments[indexPath.row];
    }
    
    [self showEnvironmentDetails:environment];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Search Results Updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    if (searchText.length == 0) {
        self.filteredEnvironments = @[];
    } else {
        NSMutableArray *filtered = [NSMutableArray array];
        
        // Search in private environments
        for (TSEnvironment *env in self.manager.privateEnvironments) {
            if ([env.name localizedCaseInsensitiveContainsString:searchText] ||
                [env.description localizedCaseInsensitiveContainsString:searchText] ||
                [env.category localizedCaseInsensitiveContainsString:searchText]) {
                [filtered addObject:env];
            }
        }
        
        // Search in public environments
        for (TSEnvironment *env in self.manager.publicEnvironments) {
            if ([env.name localizedCaseInsensitiveContainsString:searchText] ||
                [env.description localizedCaseInsensitiveContainsString:searchText] ||
                [env.category localizedCaseInsensitiveContainsString:searchText]) {
                [filtered addObject:env];
            }
        }
        
        self.filteredEnvironments = filtered;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)applyChanges {
    // Collect changes
    NSMutableDictionary *changes = [NSMutableDictionary dictionary];
    // TODO: Collect actual changes from UI
    
    // Show confirmation
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Apply Changes"
                                                                 message:@"Some changes may require reinstalling the app. Continue?"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Apply" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.manager applyChanges:changes completion:^(BOOL success, NSError *error) {
            if (success) {
                // Show success message
            } else {
                // Show error message
            }
        }];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showEnvironmentDetails:(TSEnvironment *)environment {
    // Create and push detail view controller
    UIViewController *detailVC = [[UIViewController alloc] init];
    detailVC.title = environment.name;
    
    // TODO: Add detail view implementation
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
