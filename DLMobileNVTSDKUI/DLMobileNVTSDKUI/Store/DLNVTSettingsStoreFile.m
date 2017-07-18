//
//  DLNVTSettingsStoreFile.m
//  DLMobileNVTSDKUI
//
//  Created by limingzou on 2017/7/5.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import "DLNVTSettingsStoreFile.h"
@interface DLNVTSettingsStoreFile() {
    NSMutableDictionary * _dict;
}

@end

@implementation DLNVTSettingsStoreFile

- (id)initWithPath:(NSString*)path {
    if((self = [super init])) {
        _filePath = [path copy];
        _dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        
        if(_dict == nil) {
            _dict = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)setObject:(id)value forKey:(NSString *)key {
    [_dict setObject:value forKey:key];
}

- (id)objectForKey:(NSString *)key {
    return [_dict objectForKey:key];
}

- (BOOL)synchronize {
    return [_dict writeToFile:_filePath atomically:YES];
}


@end
