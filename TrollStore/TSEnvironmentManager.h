#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSEnvironment : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, assign) BOOL requiresReinstall;
@property (nonatomic, assign) BOOL supported;
@property (nonatomic, strong) id currentValue;

@end

@interface TSEnvironmentManager : NSObject

@property (nonatomic, strong) NSArray<TSEnvironment *> *privateEnvironments;
@property (nonatomic, strong) NSArray<TSEnvironment *> *publicEnvironments;

+ (instancetype)sharedManager;

// Environment Management
- (void)setupEnvironmentLists;
- (void)applyChanges:(NSDictionary *)changes completion:(void(^)(BOOL success, NSError *error))completion;
- (TSEnvironment *)environmentForKey:(NSString *)key;

// UI Related
- (UIViewController *)environmentViewController;
- (void)showEnvironmentDetails:(TSEnvironment *)environment;

@end

NS_ASSUME_NONNULL_END
