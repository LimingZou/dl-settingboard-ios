//
//  ViewController.m
//  dl-settingboard-ios
//
//  Created by limingzou on 2017/7/9.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import "ViewController.h"
#import <DLMobileNVTSDKUI/DLMobileNVTSDKUI.h>
static NSString *const kShutdown= @"c-shutdown";
static NSString *const kInitialize= @"d-initialize";

@interface ViewController ()<DLNVTSettingBoardDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float i = 1.6666666;
    
    ;
    
    NSLog(@"test: %f",[[NSString stringWithFormat:@"%.1f",i] floatValue]);
}
- (IBAction)setupSettingBoard:(id)sender {
    [self setup];
}

- (void)setup{
    
    //设置默认模版(Settings.bundle)
    DLNVTSettingBoard *settingBoard = [DLNVTSettingBoard settingBoard];
    
    //创建自定义模版
    //    [settingBoard createBoardFile:nil];
    
    //设置代理
    [settingBoard setDelegate:self];
    
    //设置预先值
    [settingBoard userSettingsWrite:@"360全景相机" forKey:@"d-name"];
    [settingBoard userSettingsWrite:@"1.2.6" forKey:@"d-version"];
    [settingBoard userSettingsWrite:@"10086/238797521-XO" forKey:@"d-serial"];
    
    //重置
    //[settingBoard reset];
    
    //推出控制器
    UIViewController *settingVC = [settingBoard settingContainer];
    [self.navigationController pushViewController:settingVC animated:YES];
    
}

#pragma mark - <DLNVTSettingBoardDelegate>

- (void)settingsBoard:(DLNVTSettingBoard *)board valueHasChanged:(NSDictionary *)newValue success:(void (^)())success failure:(void (^)())failure{
    
    NSLog(@"被修改的值是:%@",newValue);
    __block UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"正在发送命令..." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    [alert show];
//    [[DLUITipsCenter sharedInstance] presentLoadingTips:@"正在发送命令..." inView:self.currentVC.view];
    int64_t delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alert dismissWithClickedButtonIndex:0 animated:YES];
//        [[DLUITipsCenter sharedInstance] dismissTips];
        success();
    });
}


- (void)settingsBoard:(DLNVTSettingBoard *)board buttonTappedForKey:(NSString *)key success:(void (^)())success failure:(void (^)())failure{
    if ([key isEqualToString:kShutdown]) {
        __block UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"正在关闭相机..." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];

//        [[DLUITipsCenter sharedInstance] presentLoadingTips:@"正在关闭相机..." inView:self.currentVC.view];
        int64_t delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [[DLUITipsCenter sharedInstance] dismissTips];
            [alert dismissWithClickedButtonIndex:0 animated:YES];

            success();
        });
    }else if ([key isEqualToString:kInitialize]){
        __block UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"正在初始化..." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
//        [[DLUITipsCenter sharedInstance] presentLoadingTips:@"正在初始化..." inView:self.currentVC.view];
        int64_t delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [alert dismissWithClickedButtonIndex:0 animated:YES];
//            [[DLUITipsCenter sharedInstance] dismissTips];
            success();
        });
    }
}


@end
