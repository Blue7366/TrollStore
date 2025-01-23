#import "TSLogger.h"
#import <sys/sysctl.h>
#import <mach/mach.h>

@interface TSLogger ()
@property (nonatomic, strong) NSString *logFilePath;
@property (nonatomic, strong) NSFileHandle *logFileHandle;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) dispatch_queue_t logQueue;
@end

@implementation TSLogger

+ (instancetype)sharedInstance {
    static TSLogger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TSLogger alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // Setup log file
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        _logFilePath = [documentsPath stringByAppendingPathComponent:@"trollstore.log"];
        
        // Create log file if it doesn't exist
        if (![[NSFileManager defaultManager] fileExistsAtPath:_logFilePath]) {
            [[NSFileManager defaultManager] createFileAtPath:_logFilePath contents:nil attributes:nil];
        }
        
        // Open log file
        _logFileHandle = [NSFileHandle fileHandleForWritingAtPath:_logFilePath];
        [_logFileHandle seekToEndOfFile];
        
        // Setup date formatter
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // Setup serial queue for thread-safe logging
        _logQueue = dispatch_queue_create("com.opa334.trollstore.logger", DISPATCH_QUEUE_SERIAL);
        
        // Log initial system state
        [self logSystemState];
    }
    return self;
}

- (void)logMessage:(NSString *)message level:(TSLogLevel)level {
    dispatch_async(_logQueue, ^{
        NSString *levelString;
        switch (level) {
            case TSLogLevelDebug:
                levelString = @"DEBUG";
                break;
            case TSLogLevelInfo:
                levelString = @"INFO";
                break;
            case TSLogLevelWarning:
                levelString = @"WARNING";
                break;
            case TSLogLevelError:
                levelString = @"ERROR";
                break;
            case TSLogLevelCritical:
                levelString = @"CRITICAL";
                break;
        }
        
        NSString *timestamp = [self.dateFormatter stringFromDate:[NSDate date]];
        NSString *logEntry = [NSString stringWithFormat:@"[%@] [%@] %@\n", 
                            timestamp, levelString, message];
        
        NSData *data = [logEntry dataUsingEncoding:NSUTF8StringEncoding];
        [self.logFileHandle writeData:data];
        [self.logFileHandle synchronizeFile];
        
        // Also print to console for debugging
        NSLog(@"%@", logEntry);
    });
}

- (void)logDebug:(NSString *)message {
    [self logMessage:message level:TSLogLevelDebug];
}

- (void)logInfo:(NSString *)message {
    [self logMessage:message level:TSLogLevelInfo];
}

- (void)logWarning:(NSString *)message {
    [self logMessage:message level:TSLogLevelWarning];
}

- (void)logError:(NSString *)message {
    [self logMessage:message level:TSLogLevelError];
}

- (void)logCritical:(NSString *)message {
    [self logMessage:message level:TSLogLevelCritical];
}

- (void)logExploitAttempt:(NSString *)exploitName success:(BOOL)success error:(NSError *)error {
    NSString *message;
    if (success) {
        message = [NSString stringWithFormat:@"Exploit '%@' executed successfully", exploitName];
    } else {
        message = [NSString stringWithFormat:@"Exploit '%@' failed: %@", 
                  exploitName, error ? error.localizedDescription : @"Unknown error"];
    }
    
    [self logMessage:message level:success ? TSLogLevelInfo : TSLogLevelError];
}

- (void)logKernelOperation:(NSString *)operation address:(uint64_t)address success:(BOOL)success {
    NSString *message = [NSString stringWithFormat:@"Kernel operation '%@' at address 0x%llx %@",
                        operation, address, success ? @"succeeded" : @"failed"];
    
    [self logMessage:message level:success ? TSLogLevelDebug : TSLogLevelError];
}

- (void)logAppModification:(NSString *)appPath modification:(NSString *)modification success:(BOOL)success {
    NSString *message = [NSString stringWithFormat:@"App modification '%@' for app at '%@' %@",
                        modification, appPath, success ? @"succeeded" : @"failed"];
    
    [self logMessage:message level:success ? TSLogLevelInfo : TSLogLevelError];
}

- (void)logSystemState {
    // Get iOS version
    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    [self logInfo:[NSString stringWithFormat:@"iOS Version: %ld.%ld.%ld",
                  (long)osVersion.majorVersion,
                  (long)osVersion.minorVersion,
                  (long)osVersion.patchVersion]];
    
    // Get device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *deviceModel = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    [self logInfo:[NSString stringWithFormat:@"Device Model: %@", deviceModel]];
    
    // Get memory info
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &page_size);
    host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    
    natural_t mem_used = (vm_stat.active_count +
                         vm_stat.inactive_count +
                         vm_stat.wire_count) * page_size;
    natural_t mem_free = vm_stat.free_count * page_size;
    natural_t mem_total = mem_used + mem_free;
    
    [self logInfo:[NSString stringWithFormat:@"Memory - Total: %lu MB, Used: %lu MB, Free: %lu MB",
                  mem_total / (1024*1024),
                  mem_used / (1024*1024),
                  mem_free / (1024*1024)]];
}

- (NSString *)getLogFilePath {
    return _logFilePath;
}

- (NSArray *)getRecentLogs:(NSInteger)count {
    NSString *logContent = [NSString stringWithContentsOfFile:_logFilePath 
                                                    encoding:NSUTF8StringEncoding 
                                                       error:nil];
    
    NSArray *allLines = [logContent componentsSeparatedByCharactersInSet:
                        [NSCharacterSet newlineCharacterSet]];
    
    // Get last 'count' lines
    NSInteger startIndex = allLines.count > count ? allLines.count - count : 0;
    return [allLines subarrayWithRange:NSMakeRange(startIndex, allLines.count - startIndex)];
}

- (void)dealloc {
    [_logFileHandle closeFile];
}

@end
