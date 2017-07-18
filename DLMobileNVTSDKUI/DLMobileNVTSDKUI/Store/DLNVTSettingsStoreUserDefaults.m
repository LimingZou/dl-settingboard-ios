//
//  DLNVTSettingsStoreUserDefaults.m
//  DLMobileNVTSDKUI
//
//  Created by limingzou on 2017/7/5.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import "DLNVTSettingsStoreUserDefaults.h"

@interface DLNVTSettingsStoreUserDefaults ()

@property (nonatomic, retain, readwrite) NSUserDefaults* defaults;

@end

@implementation DLNVTSettingsStoreUserDefaults

- (id)initWithUserDefaults:(NSUserDefaults *)defaults {
    self = [super init];
    if( self ) {
        _defaults = defaults;
    }
    return self;
}

- (id)init {
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (id)initWithSuiteName:(NSString *)suitename{
    self = [super init];
    if( self ) {
        _defaults = [[NSUserDefaults alloc] initWithSuiteName:suitename];
    }
    return self;
}

- (void)setBool:(BOOL)value forKey:(NSString*)key {
    [self.defaults setBool:value forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString*)key {
    [self.defaults setFloat:value forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString*)key {
    [self.defaults setDouble:value forKey:key];
}

- (void)setInteger:(NSInteger)value forKey:(NSString*)key {
    [self.defaults setInteger:value forKey:key];
}

- (void)setObject:(id)value forKey:(NSString*)key {
    [self.defaults setObject:value forKey:key];
}

- (BOOL)boolForKey:(NSString*)key {
    return [self.defaults boolForKey:key];
}

- (float)floatForKey:(NSString*)key {
    return [self.defaults floatForKey:key];
}

- (double)doubleForKey:(NSString*)key {
    return [self.defaults doubleForKey:key];
}

- (NSInteger)integerForKey:(NSString*)key {
    return [self.defaults integerForKey:key];
}

- (id)objectForKey:(NSString*)key {
    return [self.defaults objectForKey:key];
}

- (BOOL)synchronize {
    return [self.defaults synchronize];
}

- (void)reset:(NSString *)domain{
    [self.defaults removePersistentDomainForName:domain];
}
@end
