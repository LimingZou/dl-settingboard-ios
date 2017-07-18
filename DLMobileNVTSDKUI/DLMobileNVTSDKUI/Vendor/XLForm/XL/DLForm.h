//
//  DLForm.h
//  DLForm ( https://github.com/xmartlabs/DLForm )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

//Descriptors
#import "DLFormDescriptor.h"
#import "DLFormRowDescriptor.h"
#import "DLFormSectionDescriptor.h"

// Categories
#import "NSArray+DLFormAdditions.h"
#import "NSExpression+DLFormAdditions.h"
#import "NSObject+DLFormAdditions.h"
#import "NSPredicate+DLFormAdditions.h"
#import "NSString+DLFormAdditions.h"
#import "UIView+DLFormAdditions.h"

//helpers
#import "DLFormOptionsObject.h"

//Controllers
#import "DLFormOptionsViewController.h"
#import "DLFormViewController.h"

//Protocols
#import "DLFormDescriptorCell.h"
#import "DLFormInlineRowDescriptorCell.h"
#import "DLFormRowDescriptorViewController.h"

//Cells
#import "DLFormBaseCell.h"
#import "DLFormButtonCell.h"
#import "DLFormCheckCell.h"
#import "DLFormDateCell.h"
#import "DLFormDatePickerCell.h"
#import "DLFormInlineSelectorCell.h"
#import "DLFormLeftRightSelectorCell.h"
#import "DLFormPickerCell.h"
#import "DLFormRightDetailCell.h"
#import "DLFormRightImageButton.h"
#import "DLFormSegmentedCell.h"
#import "DLFormSelectorCell.h"
#import "DLFormSliderCell.h"
#import "DLFormStepCounterCell.h"
#import "DLFormSwitchCell.h"
#import "DLFormTextFieldCell.h"
#import "DLFormTextViewCell.h"
#import "DLFormImageCell.h"

//Validation
#import "DLFormRegexValidator.h"


extern NSString *const DLFormRowDescriptorTypeAccount;
extern NSString *const DLFormRowDescriptorTypeBooleanCheck;
extern NSString *const DLFormRowDescriptorTypeBooleanSwitch;
extern NSString *const DLFormRowDescriptorTypeButton;
extern NSString *const DLFormRowDescriptorTypeCountDownTimer;
extern NSString *const DLFormRowDescriptorTypeCountDownTimerInline;
extern NSString *const DLFormRowDescriptorTypeDate;
extern NSString *const DLFormRowDescriptorTypeDateInline;
extern NSString *const DLFormRowDescriptorTypeDatePicker;
extern NSString *const DLFormRowDescriptorTypeDateTime;
extern NSString *const DLFormRowDescriptorTypeDateTimeInline;
extern NSString *const DLFormRowDescriptorTypeDecimal;
extern NSString *const DLFormRowDescriptorTypeEmail;
extern NSString *const DLFormRowDescriptorTypeImage;
extern NSString *const DLFormRowDescriptorTypeInfo;
extern NSString *const DLFormRowDescriptorTypeInteger;
extern NSString *const DLFormRowDescriptorTypeMultipleSelector;
extern NSString *const DLFormRowDescriptorTypeMultipleSelectorPopover;
extern NSString *const DLFormRowDescriptorTypeName;
extern NSString *const DLFormRowDescriptorTypeNumber;
extern NSString *const DLFormRowDescriptorTypePassword;
extern NSString *const DLFormRowDescriptorTypePhone;
extern NSString *const DLFormRowDescriptorTypePicker;
extern NSString *const DLFormRowDescriptorTypeSelectorActionSheet;
extern NSString *const DLFormRowDescriptorTypeSelectorAlertView;
extern NSString *const DLFormRowDescriptorTypeSelectorLeftRight;
extern NSString *const DLFormRowDescriptorTypeSelectorPickerView;
extern NSString *const DLFormRowDescriptorTypeSelectorPickerViewInline;
extern NSString *const DLFormRowDescriptorTypeSelectorPopover;
extern NSString *const DLFormRowDescriptorTypeSelectorPush;
extern NSString *const DLFormRowDescriptorTypeSelectorSegmentedControl;
extern NSString *const DLFormRowDescriptorTypeSlider;
extern NSString *const DLFormRowDescriptorTypeStepCounter;
extern NSString *const DLFormRowDescriptorTypeText;
extern NSString *const DLFormRowDescriptorTypeTextView;
extern NSString *const DLFormRowDescriptorTypeTime;
extern NSString *const DLFormRowDescriptorTypeTimeInline;
extern NSString *const DLFormRowDescriptorTypeTwitter;
extern NSString *const DLFormRowDescriptorTypeURL;
extern NSString *const DLFormRowDescriptorTypeZipCode;


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending


