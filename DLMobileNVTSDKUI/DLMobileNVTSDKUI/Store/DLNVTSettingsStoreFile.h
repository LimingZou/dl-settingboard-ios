//
//  DLNVTSettingsStoreFile.h
//  DLMobileNVTSDKUI
//
//  Created by limingzou on 2017/7/5.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import "DLNVTSettingsStore.h"

@interface DLNVTSettingsStoreFile : DLNVTAbstractSettingsStore

- (id)initWithPath:(NSString*)path;

@property (nonatomic, copy, readonly) NSString* filePath;

@end
