#import <Foundation/Foundation.h>
#import "TSAppDelegate.h"
#import "TSUtil.h"
#import "../Exploits/kernel_exploit/main.m"

NSUserDefaults* trollStoreUserDefaults(void)
{
	return [[NSUserDefaults alloc] initWithSuiteName:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Preferences/%@.plist", APP_ID]]];
}

bool initializeJailbreak(void)
{
    NSLog(@"[*] Initializing TrollStore v2 with jailbreak capabilities...");
    
    // Check if jailbreak is already active
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb"]) {
        NSLog(@"[+] Device is already jailbroken");
        return true;
    }
    
    // Initialize and run kernel exploit
    if (!initialize_exploit()) {
        NSLog(@"[-] Failed to initialize kernel exploit");
        return false;
    }
    
    // Setup jailbreak environment
    if (!setupJailbreakEnvironment()) {
        NSLog(@"[-] Failed to setup jailbreak environment");
        return false;
    }
    
    NSLog(@"[+] Successfully initialized jailbreak");
    return true;
}

bool setupJailbreakEnvironment(void)
{
    // Create necessary directories
    NSArray *directories = @[
        @"/var/jb",
        @"/var/jb/usr/lib",
        @"/var/jb/Library/TweakInject"
    ];
    
    for (NSString *dir in directories) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dir
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil]) {
            NSLog(@"[-] Failed to create directory: %@", dir);
            return false;
        }
    }
    
    return true;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		chineseWifiFixup();
        
        // Initialize jailbreak if enabled
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enable_jailbreak"]) {
            if (!initializeJailbreak()) {
                NSLog(@"[-] Failed to initialize jailbreak");
                return 1;
            }
        }
        
		return UIApplicationMain(argc, argv, nil, NSStringFromClass(TSAppDelegate.class));
	}
}
