//
//  DLNVTSettingsStoreUserDefaults.h
//  DLMobileNVTSDKUI
//
//  Created by limingzou on 2017/7/5.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLNVTSettingsStore.h"

/** implementation of IASKSettingsStore that uses NSUserDefaults
 */
@interface DLNVTSettingsStoreUserDefaults : NSObject<DLNVTSettingsStore>

- (id)initWithUserDefaults:(NSUserDefaults*) defaults;
- (id)initWithSuiteName:(NSString *)suitename;
- (id)init;

@property (nonatomic, retain, readonly) NSUserDefaults* defaults;

@end
