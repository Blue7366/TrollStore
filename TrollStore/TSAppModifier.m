#import "TSAppModifier.h"
#import "TSUtil.h"
#import <Foundation/Foundation.h>

@implementation TSAppModifier

+ (BOOL)modifyAppEntitlements:(NSString *)appPath withEntitlements:(NSDictionary *)entitlements {
    // Create temporary directory for modification
    NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    // Extract app bundle
    NSString *appName = [appPath lastPathComponent];
    NSString *extractedPath = [tempDir stringByAppendingPathComponent:appName];
    
    if (![self extractApp:appPath toPath:extractedPath]) {
        return NO;
    }
    
    // Modify entitlements
    NSString *binaryPath = [self findBinaryInApp:extractedPath];
    if (!binaryPath) {
        return NO;
    }
    
    // Save entitlements to temp plist
    NSString *entitlementsPath = [tempDir stringByAppendingPathComponent:@"entitlements.plist"];
    [entitlements writeToFile:entitlementsPath atomically:YES];
    
    // Sign with new entitlements
    if (![self signBinary:binaryPath withEntitlements:entitlementsPath]) {
        return NO;
    }
    
    // Repack app
    if (![self repackApp:extractedPath toPath:appPath]) {
        return NO;
    }
    
    // Cleanup
    [[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
    
    return YES;
}

+ (BOOL)extractApp:(NSString *)appPath toPath:(NSString *)extractPath {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/unzip";
    task.arguments = @[@"-q", appPath, @"-d", extractPath];
    
    [task launch];
    [task waitUntilExit];
    
    return (task.terminationStatus == 0);
}

+ (NSString *)findBinaryInApp:(NSString *)appPath {
    // Parse Info.plist to find binary name
    NSString *infoPlistPath = [appPath stringByAppendingPathComponent:@"Info.plist"];
    NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
    
    NSString *binaryName = infoPlist[@"CFBundleExecutable"];
    if (!binaryName) {
        return nil;
    }
    
    return [appPath stringByAppendingPathComponent:binaryName];
}

+ (BOOL)signBinary:(NSString *)binaryPath withEntitlements:(NSString *)entitlementsPath {
    // Use ldid for signing
    NSString *ldidPath = @"/usr/bin/ldid";
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = ldidPath;
    task.arguments = @[@"-S", entitlementsPath, binaryPath];
    
    [task launch];
    [task waitUntilExit];
    
    return (task.terminationStatus == 0);
}

+ (BOOL)repackApp:(NSString *)appPath toPath:(NSString *)outputPath {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/zip";
    task.arguments = @[@"-qr", outputPath, @"."];
    task.currentDirectoryPath = appPath;
    
    [task launch];
    [task waitUntilExit];
    
    return (task.terminationStatus == 0);
}

+ (NSDictionary *)defaultEnhancedEntitlements {
    return @{
        @"platform-application": @YES,
        @"com.apple.private.security.no-sandbox": @YES,
        @"com.apple.private.security.container-manager": @YES,
        @"com.apple.private.mobileinstall.allowedSPI": @YES,
        @"task_for_pid-allow": @YES,
        @"com.apple.system-task-ports": @YES,
        @"com.apple.private.security.system-application": @YES,
        @"com.apple.private.security.disk-device-access": @YES,
        @"com.apple.private.MobileContainerManager.allowed": @YES,
        @"com.apple.private.security.storage.AppDataContainers": @YES
    };
}

@end
