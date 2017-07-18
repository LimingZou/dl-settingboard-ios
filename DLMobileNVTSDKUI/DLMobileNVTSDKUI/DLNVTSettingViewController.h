//
//  DLNVTSettingViewController.h
//  DLMobileNVTSDKUI
//
//  Created by limingzou on 2017/7/5.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import "DLForm.h"

@class DLNVTSettingViewController;
@protocol DLNVTSettingViewControllerDelegate <NSObject>

@optional
#pragma mark - respond to button taps
- (void)settingsViewController:(DLNVTSettingViewController *)sender buttonTappedForKey:(NSString*)key success:(void (^)())success failure:(void (^)())failure;

- (void)settingsViewControllerMultiple:(DLNVTSettingViewController *)sender valueHasChanged:(NSDictionary*)newValue  success:(void (^)())success failure:(void (^)())failure;

- (void)settingsViewControllerSingle:(DLNVTSettingViewController *)sender valueHasChanged:(NSDictionary*)newValue  success:(void (^)(NSString *key))success failure:(void(^)(NSString *key))failure  stop:(void(^)(BOOL *stop))stop;

- (void)settingsViewControllerFailure:(DLNVTSettingViewController *)board failureDetails:(NSMutableArray *)failureDetails shut:(void(^)())shut;

@end

@interface DLNVTSettingViewController : DLFormViewController

@property (nonatomic, assign) id <DLNVTSettingViewControllerDelegate> delegate;
@property (nonatomic, retain, readonly) NSString *error;
@property (nonatomic, assign) int model;

- (instancetype)initWithDefalutSettings:(NSDictionary *)info;

@end

@interface DLNavBarButton : UIBarButtonItem

@end
