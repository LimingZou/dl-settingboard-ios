//
//  DLNVTSettingBoard.h
//  DLMobileNVTSDKUI
//
//  Created by limingzou on 2017/7/5.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <DLMobileNVTSDKUI/DLNVTSettingProtocol.h>

extern NSString *const UserDefaultDomain;

@class DLNVTSettingBoard;
@protocol DLNVTSettingBoardDelegate <NSObject>

@optional
- (void)settingsBoard:(DLNVTSettingBoard *)board buttonTappedForKey:(NSString*)key success:(void (^)())success failure:(void (^)())failure;

- (void)settingsBoard:(DLNVTSettingBoard *)board valueHasChanged:(NSDictionary*)newValue  success:(void (^)())success failure:(void (^)())failure;
@end

@interface DLNVTSettingBoard : NSObject<DLNVTSettingProtocol>

@property (nonatomic, assign) id<DLNVTSettingBoardDelegate>delegate;

+ (instancetype)settingBoard;

- (void)createDefaultBoard;
- (void)createBoardFile:(NSString *)path;

- (UIViewController *)settingContainer;

- (id)userSettingsRead:(NSString *)key;
- (void)userSettingsWrite:(id)value forKey:(NSString *)key;

- (void)reset;
@end
