//
//  DLForm.m
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


#import "DLForm.h"

NSString *const DLFormRowDescriptorTypeText = @"text";
NSString *const DLFormRowDescriptorTypeName = @"name";
NSString *const DLFormRowDescriptorTypeURL = @"url";
NSString *const DLFormRowDescriptorTypeEmail = @"email";
NSString *const DLFormRowDescriptorTypePassword = @"password";
NSString *const DLFormRowDescriptorTypeNumber = @"number";
NSString *const DLFormRowDescriptorTypePhone = @"phone";
NSString *const DLFormRowDescriptorTypeTwitter = @"twitter";
NSString *const DLFormRowDescriptorTypeAccount = @"account";
NSString *const DLFormRowDescriptorTypeInteger = @"integer";
NSString *const DLFormRowDescriptorTypeImage = @"image";
NSString *const DLFormRowDescriptorTypeDecimal = @"decimal";
NSString *const DLFormRowDescriptorTypeTextView = @"textView";
NSString *const DLFormRowDescriptorTypeZipCode = @"zipCode";
NSString *const DLFormRowDescriptorTypeSelectorPush = @"selectorPush";
NSString *const DLFormRowDescriptorTypeSelectorPopover = @"selectorPopover";
NSString *const DLFormRowDescriptorTypeSelectorActionSheet = @"selectorActionSheet";
NSString *const DLFormRowDescriptorTypeSelectorAlertView = @"selectorAlertView";
NSString *const DLFormRowDescriptorTypeSelectorPickerView = @"selectorPickerView";
NSString *const DLFormRowDescriptorTypeSelectorPickerViewInline = @"selectorPickerViewInline";
NSString *const DLFormRowDescriptorTypeMultipleSelector = @"multipleSelector";
NSString *const DLFormRowDescriptorTypeMultipleSelectorPopover = @"multipleSelectorPopover";
NSString *const DLFormRowDescriptorTypeSelectorLeftRight = @"selectorLeftRight";
NSString *const DLFormRowDescriptorTypeSelectorSegmentedControl = @"selectorSegmentedControl";
NSString *const DLFormRowDescriptorTypeDateInline = @"dateInline";
NSString *const DLFormRowDescriptorTypeDateTimeInline = @"datetimeInline";
NSString *const DLFormRowDescriptorTypeTimeInline = @"timeInline";
NSString *const DLFormRowDescriptorTypeCountDownTimerInline = @"countDownTimerInline";
NSString *const DLFormRowDescriptorTypeDate = @"date";
NSString *const DLFormRowDescriptorTypeDateTime = @"datetime";
NSString *const DLFormRowDescriptorTypeTime = @"time";
NSString *const DLFormRowDescriptorTypeCountDownTimer = @"countDownTimer";
NSString *const DLFormRowDescriptorTypeDatePicker = @"datePicker";
NSString *const DLFormRowDescriptorTypePicker = @"picker";
NSString *const DLFormRowDescriptorTypeSlider = @"slider";
NSString *const DLFormRowDescriptorTypeBooleanCheck = @"booleanCheck";
NSString *const DLFormRowDescriptorTypeBooleanSwitch = @"booleanSwitch";
NSString *const DLFormRowDescriptorTypeButton = @"button";
NSString *const DLFormRowDescriptorTypeInfo = @"info";
NSString *const DLFormRowDescriptorTypeStepCounter = @"stepCounter";

