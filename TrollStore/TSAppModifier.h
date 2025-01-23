#import <Foundation/Foundation.h>

@interface TSAppModifier : NSObject

// Modify app entitlements dynamically
+ (BOOL)modifyAppEntitlements:(NSString *)appPath withEntitlements:(NSDictionary *)entitlements;

// Get default enhanced entitlements
+ (NSDictionary *)defaultEnhancedEntitlements;

// New methods for advanced app modification
+ (BOOL)injectDylib:(NSString *)dylibPath intoApp:(NSString *)appPath;
+ (BOOL)patchAppGroup:(NSString *)appPath withNewGroups:(NSArray *)groups;
+ (BOOL)enableJITForApp:(NSString *)appPath;
+ (BOOL)enableFileAccessForApp:(NSString *)appPath withPaths:(NSArray *)paths;
+ (BOOL)modifyInfoPlist:(NSString *)appPath withAdditions:(NSDictionary *)additions;

// Advanced security bypasses
+ (BOOL)bypassCodeSigningForApp:(NSString *)appPath;
+ (BOOL)enableDebuggingForApp:(NSString *)appPath;
+ (BOOL)patchAMFIChecksForApp:(NSString *)appPath;

@end
