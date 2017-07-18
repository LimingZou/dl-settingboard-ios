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

#pragma mark -

@interface DLFailureDetails : NSObject<NSCopying>
{
@package
    NSString * _key;
    NSString * _title;
    id _value;
}
@property (nonatomic, retain, readonly) NSString * key;
@property (nonatomic, retain, readonly) NSString * title;
@property (nonatomic, retain, readonly) id value;
@end

#pragma mark -

typedef NSMutableArray <DLFailureDetails *>* DLFailureSet;

#define MULTIPLE_MODEL   0 // server ...
#define SINGLE_MODEL     1 // server ...
#define LOCAL_MODEL      2 // local  ...

#pragma mark -

extern NSString *const UserDefaultDomain;
extern NSString *DLSettingUILocalizable(NSString *key);

#pragma mark -

@class DLNVTSettingBoard;
@protocol DLNVTSettingBoardDelegate <NSObject>
@optional

- (void)settingsBoard:(DLNVTSettingBoard *)board buttonTappedForKey:(NSString*)key success:(void (^)())success failure:(void (^)())failure;

- (void)settingsBoardMultiple:(DLNVTSettingBoard *)board valueHasChanged:(NSDictionary*)newValue  success:(void (^)())success failure:(void (^)())failure;

- (void)settingsBoardSingle:(DLNVTSettingBoard *)board valueHasChanged:(NSDictionary*)newValue  success:(void (^)(NSString *key))success failure:(void (^)(NSString *key))failure stop:(void(^)(BOOL *stop))stop;

- (void)settingsBoardFailure:(DLNVTSettingBoard *)board failureDetails:(DLFailureSet)failureDetails shut:(void(^)())shut;

@end

#pragma mark -

@interface DLNVTSettingBoard : NSObject<DLNVTSettingProtocol>

@property (nonatomic, assign) id<DLNVTSettingBoardDelegate>delegate;
@property (nonatomic, assign) int model;

+ (instancetype)settingBoard;
- (void)createDefaultBoard;
- (void)createBoardFile:(NSString *)path;
- (UIViewController *)settingContainer;
- (id)userSettingsRead:(NSString *)key;
- (void)userSettingsWrite:(id)value forKey:(NSString *)key;
- (void)reset;

@end
