//
//  LCUserPreferences.m
//  Le Code
//
//  Created by Red Davis on 08/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCUserPreferences.h"


@interface LCUserPreferences ()

@property (readonly, nonatomic) NSUserDefaults *userDefaults;

@end


static NSString *const kUsernameKey = @"com.reddavis.lecodeUsername";
static NSString *const kCredentialKey = @"com.reddavis.lecodeCredential";


@implementation LCUserPreferences

#pragma mark -

+ (LCUserPreferences *)sharedPreferences {
    
    static LCUserPreferences *userPreferences = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userPreferences = [[LCUserPreferences alloc] init];
    });
    
    return userPreferences;
}

#pragma mark - Username

- (void)setUsername:(NSString *)username {
    
    [self.userDefaults setObject:username forKey:kUsernameKey];
    [self.userDefaults synchronize];
}

- (NSString *)username {
    
    return [self.userDefaults objectForKey:kUsernameKey];
}

#pragma mark - Credentials

- (void)setCredential:(NSString *)credential {
    
    [self.userDefaults setObject:credential forKey:kCredentialKey];
    [self.userDefaults synchronize];
}

- (NSString *)credential {
    
    return [self.userDefaults objectForKey:kCredentialKey];
}

#pragma mark - Helpers

- (NSUserDefaults *)userDefaults {
    
    return [NSUserDefaults standardUserDefaults];
}

@end
