#import "TSAppEnvironmentController.h"
#import "TSLogger.h"

@interface TSAppEnvironmentController ()
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *applyButton;
@end

@implementation TSAppEnvironmentController

- (instancetype)initWithBundleIdentifier:(NSString *)bundleIdentifier {
    if (self = [super init]) {
        _bundleIdentifier = bundleIdentifier;
        _environmentVariables = [NSMutableDictionary new];
        [self loadEnvironmentVariables];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Environment Variables";
    
    // Setup TableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    // Add Button
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                  target:self
                                                                  action:@selector(addEnvironmentVariable)];
    
    // Apply Button
    self.applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply"
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(applyAndSave)];
    
    self.navigationItem.rightBarButtonItems = @[self.addButton, self.applyButton];
}

#pragma mark - Environment Variables Management

- (void)loadEnvironmentVariables {
    NSString *envPath = [NSString stringWithFormat:@"/var/containers/Bundle/Application/%@/.env", self.bundleIdentifier];
    NSString *envContent = [NSString stringWithContentsOfFile:envPath encoding:NSUTF8StringEncoding error:nil];
    
    if (envContent) {
        NSArray *lines = [envContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        for (NSString *line in lines) {
            NSArray *components = [line componentsSeparatedByString:@"="];
            if (components.count == 2) {
                self.environmentVariables[components[0]] = components[1];
            }
        }
    }
    
    [[TSLogger sharedInstance] logInfo:[NSString stringWithFormat:@"Loaded environment variables for %@", self.bundleIdentifier]];
}

- (void)saveEnvironmentVariables {
    NSMutableString *envContent = [NSMutableString new];
    [self.environmentVariables enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [envContent appendFormat:@"%@=%@\n", key, value];
    }];
    
    NSString *envPath = [NSString stringWithFormat:@"/var/containers/Bundle/Application/%@/.env", self.bundleIdentifier];
    [envContent writeToFile:envPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [[TSLogger sharedInstance] logInfo:[NSString stringWithFormat:@"Saved environment variables for %@", self.bundleIdentifier]];
}

- (void)applyEnvironmentVariables {
    // Get app container path
    NSString *containerPath = [NSString stringWithFormat:@"/var/containers/Bundle/Application/%@", self.bundleIdentifier];
    
    // Create or update environment.plist
    NSString *plistPath = [containerPath stringByAppendingPathComponent:@"environment.plist"];
    [self.environmentVariables writeToFile:plistPath atomically:YES];
    
    // Modify app's launch daemon to include environment variables
    NSString *launchDaemonPath = [NSString stringWithFormat:@"/Library/LaunchDaemons/%@.plist", self.bundleIdentifier];
    NSMutableDictionary *launchDaemon = [NSMutableDictionary dictionaryWithContentsOfFile:launchDaemonPath];
    
    if (!launchDaemon) {
        launchDaemon = [NSMutableDictionary new];
    }
    
    launchDaemon[@"EnvironmentVariables"] = self.environmentVariables;
    [launchDaemon writeToFile:launchDaemonPath atomically:YES];
    
    [[TSLogger sharedInstance] logInfo:[NSString stringWithFormat:@"Applied environment variables for %@", self.bundleIdentifier]];
}

- (void)applyAndSave {
    [self saveEnvironmentVariables];
    [self applyEnvironmentVariables];
    
    // Show success alert
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                 message:@"Environment variables have been applied and saved"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                          handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UI Actions

- (void)addEnvironmentVariable {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Environment Variable"
                                                                 message:nil
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Key";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Value";
    }];
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        NSString *key = alert.textFields[0].text;
        NSString *value = alert.textFields[1].text;
        
        if (key.length > 0 && value.length > 0) {
            self.environmentVariables[key] = value;
            [self.tableView reloadData];
        }
    }];
    
    [alert addAction:addAction];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.environmentVariables.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EnvVarCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *key = self.environmentVariables.allKeys[indexPath.row];
    NSString *value = self.environmentVariables[key];
    
    cell.textLabel.text = key;
    cell.detailTextLabel.text = value;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *key = self.environmentVariables.allKeys[indexPath.row];
        [self.environmentVariables removeObjectForKey:key];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = self.environmentVariables.allKeys[indexPath.row];
    NSString *currentValue = self.environmentVariables[key];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit Environment Variable"
                                                                 message:nil
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = key;
        textField.placeholder = @"Key";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = currentValue;
        textField.placeholder = @"Value";
    }];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        NSString *newKey = alert.textFields[0].text;
        NSString *newValue = alert.textFields[1].text;
        
        if (newKey.length > 0 && newValue.length > 0) {
            [self.environmentVariables removeObjectForKey:key];
            self.environmentVariables[newKey] = newValue;
            [self.tableView reloadData];
        }
    }];
    
    [alert addAction:saveAction];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
