//
//  DLNVTSettingViewController.m
//  DLMobileNVTSDKUI
//
//  Created by limingzou on 2017/7/5.
//  Copyright © 2017年 limingzou. All rights reserved.
//

#import "DLNVTSettingViewController.h"

#import "DLNVTSettingBoard.h"

#import "DLNVTSettingsStoreUserDefaults.h"

#import "DLStatusBarNotification.h"

#define FONT_SIZE 12.0f

// lasted new values changed
void DLValueCompare (NSDictionary *value1, NSDictionary *value2, NSMutableDictionary **result) {
    [value1 enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull cKey, id  _Nonnull cObj, BOOL * _Nonnull stop) {
       [value2 enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
           if ([cKey isEqual:key]) {
               if (![cObj isEqual:obj]) {
                   [*result setValue:obj forKey:key];
               }
           }
       }];
    }];
    
}

@interface DLNVTSettingViewController ()
{
    NSDictionary * _oldFormValues;
    NSString * _error;
    UIBarButtonItem * _indicatorButton;
    UIBarButtonItem * _submitButton;
    __unsafe_unretained id <DLNVTSettingViewControllerDelegate> _delegate;
    int _model;
    DLFailureSet _failureSet;
}

@property (nonatomic, retain) UIBarButtonItem * indicatorButton;
@property (nonatomic, retain) UIBarButtonItem * submitButton;
@property (nonatomic, retain) DLStatusBarNotification *notification;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) DLFailureSet failureSet;


@end


@implementation DLNVTSettingViewController

@synthesize submitButton = _submitButton;
@synthesize indicatorButton = _indicatorButton;
@synthesize error = _error;
@synthesize delegate = _delegate;
@synthesize model = _model;
@synthesize notification = _notification;
@synthesize statusLabel = _statusLabel;
@synthesize failureSet = _failureSet;

- (instancetype)initWithDefalutSettings:(NSDictionary *)info{
    self = [super init];
    if (self) {
        [self initializeForm:info];
    }
    return self;
}


-(void)initializeForm:(NSDictionary *)info
{
    
    self.title = DLSettingUILocalizable(info[@"Title"]);
    DLFormDescriptor * form = [DLFormDescriptor formDescriptor];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        DLFormSectionDescriptor * section;
        DLFormRowDescriptor * row;
        for (NSDictionary *sectionDict in info[@"sections"]) {
            section = [DLFormSectionDescriptor formSectionWithTitle:DLSettingUILocalizable(sectionDict[@"Title"])];
            section.footerTitle = DLSettingUILocalizable(sectionDict[@"FooterTitle"]);
            [form addFormSection:section];
            for (NSDictionary *rowDict in sectionDict[@"rows"]) {
                if ([rowDict[@"Type"] isEqualToString:DLFormRowDescriptorTypeSelectorPush]) {
                    row = [DLFormRowDescriptor formRowDescriptorWithTag:rowDict[@"Key"] rowType:DLFormRowDescriptorTypeSelectorPush title:DLSettingUILocalizable(rowDict[@"Title"])];
                    NSMutableArray <DLFormOptionsObject *> *options = [NSMutableArray array];
                    for (NSDictionary *option in rowDict[@"Options"]) {
                        [options addObject:[DLFormOptionsObject formOptionsObjectWithValue:option[@"Value"] displayText:option[@"Key"] ]];
                    }
                    row.selectorTitle = DLSettingUILocalizable(rowDict[@"Title"]);
                    row.selectorOptions = options;
                    row.required = YES;
                    row.disabled = rowDict[@"Disabled"];
                    row.value = [DLFormOptionsObject formOptionsOptionForValue:[[DLNVTSettingBoard settingBoard] userSettingsRead:rowDict[@"Key"]] ?: rowDict[@"DefaultValue"] fromOptions:options];
                    [section addFormRow:row];
                    
                }else if ([rowDict[@"Type"] isEqualToString:DLFormRowDescriptorTypeSlider]){
                    row = [DLFormRowDescriptor formRowDescriptorWithTag:rowDict[@"Key"] rowType:DLFormRowDescriptorTypeSlider title:DLSettingUILocalizable(rowDict[@"Title"])];
                    row.value = [[DLNVTSettingBoard settingBoard] userSettingsRead:rowDict[@"Key"]] ?: rowDict[@"DefaultValue"];
                    [row.cellConfigAtConfigure setObject:rowDict[@"MaximumValue"] forKey:@"slider.maximumValue"];
                    [row.cellConfigAtConfigure setObject:rowDict[@"MinimumValue"] forKey:@"slider.minimumValue"];
                    [row.cellConfigAtConfigure setObject:rowDict[@"Steps"] forKey:@"steps"];
                    [section addFormRow:row];
                }else if ([rowDict[@"Type"] isEqualToString:DLFormRowDescriptorTypeBooleanSwitch]){
                    row = [DLFormRowDescriptor formRowDescriptorWithTag:rowDict[@"Key"] rowType:DLFormRowDescriptorTypeBooleanSwitch title:DLSettingUILocalizable(rowDict[@"Title"])];
                    row.value = [[DLNVTSettingBoard settingBoard] userSettingsRead:rowDict[@"Key"]] ?: rowDict[@"DefaultValue"];
                    [section addFormRow:row];
                }else if ([rowDict[@"Type"] isEqualToString:DLFormRowDescriptorTypeInfo]){
                    row = [DLFormRowDescriptor formRowDescriptorWithTag:rowDict[@"Key"] rowType:DLFormRowDescriptorTypeInfo title:DLSettingUILocalizable(rowDict[@"Title"])];
                    row.value = [[DLNVTSettingBoard settingBoard] userSettingsRead:rowDict[@"Key"]] ?: rowDict[@"DefaultValue"];
                    [section addFormRow:row];
                }else if ([rowDict[@"Type"] isEqualToString:DLFormRowDescriptorTypeButton]){
                    row = [DLFormRowDescriptor formRowDescriptorWithTag:rowDict[@"Key"] rowType:DLFormRowDescriptorTypeButton title:DLSettingUILocalizable(rowDict[@"Title"])];
                    row.action.formSelector = @selector(didTouchButton:);
                    row.value = [[DLNVTSettingBoard settingBoard] userSettingsRead:rowDict[@"Key"]] ?: rowDict[@"DefaultValue"];
                    [section addFormRow:row];
                }
                
                
            }
            
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.form = form;
            _oldFormValues = self.availableData;
        });
        
    });

}

- (DLFailureSet)failureSet{
    if (!_failureSet) {
        _failureSet = [NSMutableArray array];
    }
    return _failureSet;
}

- (UIBarButtonItem *)indicatorButton{
    
    if (!_indicatorButton) {
        UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator setColor:self.navigationController.navigationBar.tintColor];
        [indicator setHidesWhenStopped:YES];
        [indicator startAnimating];
        [activityView addSubview:indicator];
        _indicatorButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    }

    return _indicatorButton;
}

- (UIBarButtonItem *)submitButton{
    if (!_submitButton) {
        _submitButton = [[UIBarButtonItem alloc] initWithTitle:DLSettingUILocalizable(@"setting.common.submit") style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(submitEvent:)];
    }
    return _submitButton;
}

- (UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [UILabel new];
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.backgroundColor = self.view.tintColor;
    }
    return _statusLabel;
}

- (DLStatusBarNotification *)notification{
    if (!_notification) {
        _notification = [DLStatusBarNotification new];
        _notification.notificationLabelBackgroundColor = self.navigationController.navigationBar.tintColor;
        _notification.notificationAnimationInStyle  = DLNotificationAnimationStyleTop;
        _notification.notificationAnimationOutStyle = DLNotificationAnimationStyleTop;
        _notification.notificationStyle = DLNotificationStyleStatusBarNotification;
    }
    return _notification;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.rowHeight = 54;
    [self.tableView reloadData];

    self.navigationItem.rightBarButtonItem = self.submitButton;
    
    if (self.presentingViewController) {
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithTitle:DLSettingUILocalizable(@"setting.common.cancel") style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(cancelEvent:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }

}
- (void)cancelEvent:(UIBarButtonItem *)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[DLNVTSettingBoard settingBoard].settingsStore isKindOfClass:[DLNVTSettingsStoreUserDefaults class]]) {
        NSNotificationCenter *dc = NSNotificationCenter.defaultCenter;
        DLNVTSettingsStoreUserDefaults *udSettingsStore = (id)[DLNVTSettingBoard settingBoard].settingsStore;
        [dc addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:udSettingsStore.defaults];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.notification dismissNotification];

    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    if ([[DLNVTSettingBoard settingBoard].settingsStore isKindOfClass:[DLNVTSettingsStoreUserDefaults class]]) {
        DLNVTSettingsStoreUserDefaults *udSettingsStore = (id)[DLNVTSettingBoard settingBoard].settingsStore;
        [dc removeObserver:self name:NSUserDefaultsDidChangeNotification object:udSettingsStore.defaults];
    }
}

- (void)userDefaultsDidChange:(NSNotification *)notification{
}

- (void)setRequestState:(BOOL)flag{
    if (flag) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.navigationItem setRightBarButtonItem:self.indicatorButton animated:YES];
    }else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.navigationItem setRightBarButtonItem:self.submitButton animated:YES];

    }
    self.form.disabled = flag;
    [self.tableView endEditing:YES];
    [self.tableView reloadData];
}

-(void)didTouchButton:(DLFormRowDescriptor *)sender
{
    [self setRequestState:YES];
    if ([_delegate respondsToSelector:@selector(settingsViewController:buttonTappedForKey:success:failure:)]) {
        [_delegate settingsViewController:self buttonTappedForKey:sender.tag success:^{

            [self setRequestState:NO];
            [self pushLastViewController];
        } failure:^{
            [self setRequestState:NO];
            _error = @"signal failure!";
        }];
    }
}
-(void)submitEvent:(UIBarButtonItem *)button
{
    [_failureSet removeAllObjects];
    NSDictionary *newFormValues = self.availableData;
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    DLValueCompare(_oldFormValues, newFormValues, &result);
    if ( _model == LOCAL_MODEL) {
        [result enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [[DLNVTSettingBoard settingBoard] userSettingsWrite:obj forKey:key];
        }];
        [self pushLastViewController];

    }else if ( _model == MULTIPLE_MODEL) {
        [self setRequestState:YES];
        if ([_delegate respondsToSelector:@selector(settingsViewControllerMultiple:valueHasChanged:success:failure:)]) {
            [_delegate settingsViewControllerMultiple:self valueHasChanged:result success:^{
                [self setRequestState:NO];
                [result enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [[DLNVTSettingBoard settingBoard] userSettingsWrite:obj forKey:key];
                }];
                
                [self pushLastViewController];
            } failure:^{
                [self setRequestState:NO];
                _error = @"signal failure!";
            }];
        }
    }else if ( _model == SINGLE_MODEL) {
        [self setRequestState:YES];
        
        //+++++++
//        [result enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//            
//           UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:[self.form formRowWithTag:key]]];
//            cell.contentView.backgroundColor = [UIColor lightGrayColor];
//        }];
        //+++++++
        
        __block uint8_t i = 0;
        __block uint8_t si = 0;
        
        self.statusLabel.text = DLSettingUILocalizable(@"setting.common.request");
        [self.notification displayNotificationWithView:self.statusLabel forDuration:INTMAX_MAX];

        if ([_delegate respondsToSelector:@selector(settingsViewControllerSingle:valueHasChanged:success:failure:stop:)]) {
            [_delegate settingsViewControllerSingle:self valueHasChanged:result success:^(NSString *key) {
                DLFormRowDescriptor *formRow = [self.form formRowWithTag:key];
                
                self.statusLabel.text = [NSString stringWithFormat:@"%@ %@",formRow.title, DLSettingUILocalizable(@"setting.common.success")];
                
//                //+++++++
//                UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:formRow]];
//                cell.contentView.backgroundColor = [UIColor greenColor];
//                //+++++++
                
                
                [result enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull rKey, id  _Nonnull rObj, BOOL * _Nonnull rStop) {
                    if ([key isEqual:rKey]) {
                        [[DLNVTSettingBoard settingBoard] userSettingsWrite:rObj forKey:rKey];
                        [_oldFormValues setValue:rObj forKey:rKey];
                        
                    }
                }];
                
                i++;
                si++;
                if (i == result.count) {
                    [self.notification dismissNotification];
                    [self setRequestState:NO];
                    BOOL stopValue = si == result.count ? YES : NO;
                    if ( YES == stopValue) {
                        [self pushLastViewController];
                    }else{
                        if ([_delegate respondsToSelector:@selector(settingsViewControllerFailure:failureDetails:shut:)]) {
                            [_delegate settingsViewControllerFailure:self failureDetails:self.failureSet shut:^{
                                [self pushLastViewController];
                            }];
                        }
                    }
                    
                }


            } failure:^(NSString *key) {
                DLFormRowDescriptor *formRow = [self.form formRowWithTag:key];
                self.statusLabel.text = [NSString stringWithFormat:@"%@ %@",formRow.title, DLSettingUILocalizable(@"setting.common.fail")];                DLFailureDetails *failureDetail = [[DLFailureDetails alloc] init];
                failureDetail->_title = formRow.title;
                failureDetail->_key = formRow.tag;
                failureDetail->_value = formRow.value;
                
                [self.failureSet addObject:failureDetail];
                
                //+++++++
//                UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:formRow]];
//                cell.contentView.backgroundColor = [UIColor redColor];
                //+++++++
                
                i++;
                if (i == result.count) {
                    [self setRequestState:NO];
                    [self.notification dismissNotification];
                    
                    if ([_delegate respondsToSelector:@selector(settingsViewControllerFailure:failureDetails:shut:)]) {
                        [_delegate settingsViewControllerFailure:self failureDetails:self.failureSet shut:^{
                            [self pushLastViewController];
                        }];
                    }
                }
                
            } stop:^(BOOL *stop) {
                [self setRequestState:NO];
                if ( YES == *stop) {
                    [self pushLastViewController];
                }
            }];
        }
    }

    

    
}
-(void)formRowDescriptorValueHasChanged:(DLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue{
    
    if ([_oldFormValues isEqual:self.availableData]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (NSDictionary *)availableData{
    NSMutableDictionary *newFormValues = [NSMutableDictionary dictionaryWithDictionary:self.form.formValues];
    [newFormValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [newFormValues setValue:obj forKey:key];
            
        }else if ([obj isKindOfClass:[DLFormOptionsObject class]]){
            DLFormOptionsObject *option = (DLFormOptionsObject *)obj;
            [newFormValues setValue:option.formValue forKey:key];
        }else if ([obj isKindOfClass:[NSNumber class]]){
            [newFormValues setValue:obj forKey:key];
        }else if ([obj isKindOfClass:[NSString class]]){
            [newFormValues setValue:obj forKey:key];
        }
    }];
    return newFormValues;
}

- (void)pushLastViewController{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)dealloc{
    
}
@end
