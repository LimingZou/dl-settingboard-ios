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

}
- (IBAction)setupSettingBoard:(id)sender {
    [self setup];
}

- (void)setup{
    
    //设置模版
    DLNVTSettingBoard *settingBoard = [DLNVTSettingBoard settingBoard];
    
    //创建自定义模版
    //    [settingBoard createBoardFile:nil];
    
    //设置代理
    [settingBoard setDelegate:self];
    
    //设置模式 MULTIPLE_MODEL(需服务器支持): 命令集处理 SINGLE_MODEL:单命令处理  LOCAL_MODEL:用于本地设置
    [settingBoard setModel:SINGLE_MODEL];
    
    //设置预先值 (默认模版里有值, 从服务器获取获取相机设置信息后需要替换)
    [settingBoard userSettingsWrite:@"360全景相机" forKey:@"d-name"];
    [settingBoard userSettingsWrite:@"1.2.6" forKey:@"d-version"];
    [settingBoard userSettingsWrite:@"10086/238797521-XO" forKey:@"d-serial"];
    
    //重置 (需服务器支持)
    //[settingBoard reset];
    
    //推出控制器
    UIViewController *settingVC = [settingBoard settingContainer];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:settingVC] animated:YES completion:nil];
    
}

#pragma mark - <DLNVTSettingBoardDelegate>

- (void)POSTRequest:(NSTimeInterval)delay responseSuccend:(void(^)())succend failure:(void(^)())failure{
    int64_t delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (arc4random()%2 == 0) {
            succend();
        }else{
            failure();
        }
    });
}


//只能处理命令集 需要服务器支持
- (void)settingsBoardMultiple:(DLNVTSettingBoard *)board valueHasChanged:(NSDictionary *)newValue success:(void (^)())success failure:(void (^)())failure{
    NSLog(@"你修改的值是:%@",newValue);
    [self POSTRequest:3 responseSuccend:^{
        success();
    } failure:^{
        failure();
    }];
    
}

//单个命令处理
- (void)settingsBoardSingle:(DLNVTSettingBoard *)board valueHasChanged:(NSDictionary *)newValue success:(void (^)(NSString *))success failure:(void (^)(NSString *))failure stop:(void (^)(BOOL *))stop{
    NSLog(@"你修改的值是:%@",newValue);
    __block NSArray *i = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13];
    __block int indext = 0;
    [newValue enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stopn) {
        indext ++;
        [self POSTRequest:[i[indext] intValue] responseSuccend:^{
            success(key);
        } failure:^{
            failure(key);
        }];
    }];
    
}

- (void)settingsBoard:(DLNVTSettingBoard *)board buttonTappedForKey:(NSString *)key success:(void (^)())success failure:(void (^)())failure{
    if ([key isEqualToString:kShutdown]) {
//        [[DLUITipsCenter sharedInstance] presentLoadingTips:@"正在关闭相机..." inView:self.currentVC.view];
        int64_t delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //[[DLUITipsCenter sharedInstance] dismissTips];
            success();
        });
    }else if ([key isEqualToString:kInitialize]){
        //[[DLUITipsCenter sharedInstance] presentLoadingTips:@"正在初始化..." inView:self.currentVC.view];
        int64_t delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //[[DLUITipsCenter sharedInstance] dismissTips];
            success();
        });
    }
}

- (void)settingsBoardFailure:(DLNVTSettingBoard *)board failureDetails:(DLFailureSet)failureDetails{
    DLFailureSet failureSet = failureDetails;
    [failureSet enumerateObjectsUsingBlock:^(DLFailureDetails * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"发送失败的指令key:%@, title:%@",obj.key, obj.title);
    }];
}


@end
