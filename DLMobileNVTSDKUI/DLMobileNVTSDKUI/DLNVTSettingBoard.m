//
//  DLNVTSettingBoard.m
//  DLMobileNVTSDKUI
//
//  Created by limingzou on 2017/7/5.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import "DLNVTSettingBoard.h"
#import "DLNVTSettingViewController.h"

#import "DLNVTSettingsStoreUserDefaults.h"


NSString *DLSettingUILocalizable(NSString *key){
    NSString *localizedString =NSLocalizedStringFromTableInBundle(key, @"SettingLocalizable", [NSBundle bundleWithPath:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"Settings.bundle"]], nil);
    return localizedString ? localizedString : @"";
}

NSString *const UserDefaultDomain = @"com.settingStore.cn";

@implementation DLFailureDetails

@synthesize key    = _key;
@synthesize title  = _title;
@synthesize value  = _value;
- (id)copyWithZone:(NSZone *)zone
{
    DLFailureDetails *copy = [[[self class] allocWithZone:zone] init];
    copy -> _key = [_key copyWithZone:zone];
    copy -> _title = [_title copyWithZone:zone];
    copy -> _value = [_value copyWithZone:zone];
    return copy;
}

@end

@interface DLNVTSettingBoard()<DLNVTSettingViewControllerDelegate>
{
    NSString * _pathName;
    id<DLNVTSettingsStore>  _settingsStore;
    __unsafe_unretained id<DLNVTSettingBoardDelegate> _delegate;
    int _model;
}

@end

@implementation DLNVTSettingBoard

@synthesize delegate = _delegate;
@synthesize settingsStore = _settingsStore;
@synthesize model = _model;

+ (instancetype)settingBoard{
    static DLNVTSettingBoard *_settingBoard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _settingBoard = [[DLNVTSettingBoard alloc] init];
        _settingBoard -> _model = MULTIPLE_MODEL;
    });
    return _settingBoard;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createDefaultBoard];
    }
    return self;
}
- (id<DLNVTSettingsStore>)settingsStore {
    if (!_settingsStore) {
        _settingsStore = [[DLNVTSettingsStoreUserDefaults alloc] initWithSuiteName:UserDefaultDomain];
    }
    return _settingsStore;
}

- (void)createDefaultBoard{
    [self createBoardFile:[[NSBundle mainBundle] pathForResource:@"Settings.bundle/root.plist" ofType:nil]];
}

- (void)createBoardFile:(NSString *)path{

    _pathName = path;
}

- (UIViewController *)settingContainer{
    DLNVTSettingViewController *settingVC = [[DLNVTSettingViewController alloc] initWithDefalutSettings:[NSDictionary dictionaryWithContentsOfFile:_pathName]];
    settingVC.delegate = self;
    settingVC.model = _model;
    return settingVC;
}

- (void)settingsViewController:(DLNVTSettingViewController *)sender buttonTappedForKey:(NSString *)key success:(void (^)())success failure:(void (^)())failure{
    if ([_delegate respondsToSelector:@selector(settingsBoard:buttonTappedForKey:success:failure:)]) {
        [_delegate settingsBoard:self buttonTappedForKey:key success:success failure:failure];
    }
}

- (void)settingsViewControllerMultiple:(DLNVTSettingViewController *)sender valueHasChanged:(NSDictionary *)newValue success:(void (^)())success failure:(void (^)())failure{
    if ([_delegate respondsToSelector:@selector(settingsBoardMultiple:valueHasChanged:success:failure:)]) {
        [_delegate settingsBoardMultiple:self valueHasChanged:newValue success:success failure:failure];
    }
}

- (void)settingsViewControllerSingle:(DLNVTSettingViewController *)sender valueHasChanged:(NSDictionary *)newValue success:(void (^)(NSString *))success failure:(void (^)(NSString *))failure stop:(void (^)(BOOL *))stop{
    if ([_delegate respondsToSelector:@selector(settingsBoardSingle:valueHasChanged:success:failure:stop:)]) {
        [_delegate settingsBoardSingle:self valueHasChanged:newValue success:success failure:failure stop:stop];
    }
}

- (void)settingsViewControllerFailure:(DLNVTSettingViewController *)board failureDetails:(NSMutableArray *)failureDetails shut:(void(^)())shut{
    if ([_delegate respondsToSelector:@selector(settingsBoardFailure:failureDetails:shut:)]) {
        [_delegate settingsBoardFailure:self failureDetails:failureDetails shut:shut];
    }
}

- (id)userSettingsRead:(NSString *)key{
    return [self.settingsStore objectForKey:key];
}

- (void)userSettingsWrite:(id)value forKey:(NSString *)key{    
    [self.settingsStore setObject:value forKey:key];
    [self.settingsStore synchronize];

}


- (void)reset{
    [self.settingsStore reset:UserDefaultDomain];
    [self.settingsStore synchronize];
}


- (void)dealloc{

}
@end

