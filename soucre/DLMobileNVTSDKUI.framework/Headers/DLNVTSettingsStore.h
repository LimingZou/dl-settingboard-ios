//
//  DLNVTSettingsStore.h
//  DLMobileNVTSDKUI
//
//  Created by limingzou on 2017/7/5.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DLNVTSettingsStore <NSObject>

@required
- (void)setBool:(BOOL)value forKey:(NSString*)key;
- (void)setFloat:(float)value forKey:(NSString*)key;
- (void)setDouble:(double)value forKey:(NSString*)key;
- (void)setInteger:(NSInteger)value forKey:(NSString*)key;
- (void)setObject:(id)value forKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;
- (float)floatForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;
- (NSInteger)integerForKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;
- (void)reset:(NSString *)domain;
- (BOOL)synchronize;

@end

@interface DLNVTAbstractSettingsStore : NSObject <DLNVTSettingsStore>


- (void)setObject:(id)value forKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;
- (BOOL)synchronize;

@end

