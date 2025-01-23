#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TSLogLevel) {
    TSLogLevelDebug,
    TSLogLevelInfo,
    TSLogLevelWarning,
    TSLogLevelError,
    TSLogLevelCritical
};

@interface TSLogger : NSObject

+ (instancetype)sharedInstance;

// Basic logging
- (void)logMessage:(NSString *)message level:(TSLogLevel)level;
- (void)logDebug:(NSString *)message;
- (void)logInfo:(NSString *)message;
- (void)logWarning:(NSString *)message;
- (void)logError:(NSString *)message;
- (void)logCritical:(NSString *)message;

// Exploit specific logging
- (void)logExploitAttempt:(NSString *)exploitName success:(BOOL)success error:(NSError *)error;
- (void)logKernelOperation:(NSString *)operation address:(uint64_t)address success:(BOOL)success;

// App modification logging
- (void)logAppModification:(NSString *)appPath modification:(NSString *)modification success:(BOOL)success;

// System state logging
- (void)logSystemState;
- (NSString *)getLogFilePath;
- (NSArray *)getRecentLogs:(NSInteger)count;

@end
