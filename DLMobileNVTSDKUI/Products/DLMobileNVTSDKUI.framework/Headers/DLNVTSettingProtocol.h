//
//  DLNVTSettingProtocol.h
//  DLMobileNVTSDKUI
//
//  Created by limingzou on 2017/7/7.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DLNVTSettingsStore;
@protocol DLNVTSettingProtocol <NSObject>

@property (nonatomic, retain) id<DLNVTSettingsStore> settingsStore;

@end
