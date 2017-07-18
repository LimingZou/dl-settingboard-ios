//
//  DLFormRowDescriptor.h
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
#import "DLFormBaseCell.h"
#import "DLFormValidatorProtocol.h"
#import "DLFormValidationStatus.h"

extern CGFloat DLFormUnspecifiedCellHeight;

@class DLFormViewController;
@class DLFormSectionDescriptor;
@protocol DLFormValidatorProtocol;
@class DLFormAction;
@class DLFormBaseCell;

typedef NS_ENUM(NSUInteger, DLFormPresentationMode) {
    DLFormPresentationModeDefault = 0,
    DLFormPresentationModePush,
    DLFormPresentationModePresent
};

typedef void(^XLOnChangeBlock)(id __nullable oldValue,id __nullable newValue,DLFormRowDescriptor* __nonnull rowDescriptor);

@interface DLFormRowDescriptor : NSObject

@property (nullable) id cellClass;
@property (readwrite, nullable) NSString * tag;
@property (readonly, nonnull) NSString * rowType;
@property (nullable) NSString * title;
@property (nonatomic, nullable) id value;
@property (nullable) Class valueTransformer;
@property UITableViewCellStyle cellStyle;
@property (nonatomic) CGFloat height;

@property (copy, nullable) XLOnChangeBlock onChangeBlock;
@property BOOL useValueFormatterDuringInput;
@property (nullable) NSFormatter *valueFormatter;

// returns the display text for the row descriptor, taking into account NSFormatters and default placeholder values
- (nonnull NSString *) displayTextValue;

// returns the editing text value for the row descriptor, taking into account NSFormatters.
- (nonnull NSString *) editTextValue;

@property (nonatomic, readonly, nonnull) NSMutableDictionary * cellConfig;
@property (nonatomic, readonly, nonnull) NSMutableDictionary * cellConfigForSelector;
@property (nonatomic, readonly, nonnull) NSMutableDictionary * cellConfigIfDisabled;
@property (nonatomic, readonly, nonnull) NSMutableDictionary * cellConfigAtConfigure;

@property (nonnull) id disabled;
-(BOOL)isDisabled;
@property (nonnull) id hidden;
-(BOOL)isHidden;
@property (getter=isRequired) BOOL required;

@property (nonnull) DLFormAction * action;

@property (weak, null_unspecified) DLFormSectionDescriptor * sectionDescriptor;

+(nonnull instancetype)formRowDescriptorWithTag:(nullable NSString *)tag rowType:(nonnull NSString *)rowType;
+(nonnull instancetype)formRowDescriptorWithTag:(nullable NSString *)tag rowType:(nonnull NSString *)rowType title:(nullable NSString *)title;
-(nonnull instancetype)initWithTag:(nullable NSString *)tag rowType:(nonnull NSString *)rowType title:(nullable NSString *)title;

-(nonnull DLFormBaseCell *)cellForFormController:(nonnull DLFormViewController *)formController;

@property (nullable) NSString *requireMsg;
-(void)addValidator:(nonnull id<DLFormValidatorProtocol>)validator;
-(void)removeValidator:(nonnull id<DLFormValidatorProtocol>)validator;
-(nullable DLFormValidationStatus *)doValidation;

// ===========================
// property used for Selectors
// ===========================
@property (nullable) NSString * noValueDisplayText;
@property (nullable) NSString * selectorTitle;
@property (nullable) NSArray * selectorOptions;

@property (null_unspecified) id leftRightSelectorLeftOptionSelected;


// =====================================
// Deprecated
// =====================================
@property (null_unspecified) Class buttonViewController DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("Use action.viewControllerClass instead");
@property DLFormPresentationMode buttonViewControllerPresentationMode DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use action.viewControllerPresentationMode instead");
@property (null_unspecified) Class selectorControllerClass DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("Use action.viewControllerClass instead");


@end

typedef NS_ENUM(NSUInteger, DLFormLeftRightSelectorOptionLeftValueChangePolicy)
{
    DLFormLeftRightSelectorOptionLeftValueChangePolicyNullifyRightValue = 0,
    DLFormLeftRightSelectorOptionLeftValueChangePolicyChooseFirstOption,
    DLFormLeftRightSelectorOptionLeftValueChangePolicyChooseLastOption
};


// =====================================
// helper object used for LEFTRIGHTSelector Descriptor
// =====================================
@interface DLFormLeftRightSelectorOption : NSObject

@property (nonatomic, assign) DLFormLeftRightSelectorOptionLeftValueChangePolicy leftValueChangePolicy;
@property (readonly, nonnull) id leftValue;
@property (readonly, nonnull) NSArray *  rightOptions;
@property (readonly, null_unspecified) NSString * httpParameterKey;
@property (nullable) Class rightSelectorControllerClass;

@property (nullable) NSString * noValueDisplayText;
@property (nullable) NSString * selectorTitle;


+(nonnull DLFormLeftRightSelectorOption *)formLeftRightSelectorOptionWithLeftValue:(nonnull id)leftValue
                                                          httpParameterKey:(null_unspecified NSString *)httpParameterKey
                                                              rightOptions:(nonnull NSArray *)rightOptions;


@end


@protocol DLFormOptionObject

@required

-(nonnull NSString *)formDisplayText;
-(nonnull id)formValue;

@end

@interface DLFormAction : NSObject

@property (nullable, nonatomic, strong) Class viewControllerClass;
@property (nullable, nonatomic, strong) NSString * viewControllerStoryboardId;
@property (nullable, nonatomic, strong) NSString * viewControllerNibName;

@property (nonatomic) DLFormPresentationMode viewControllerPresentationMode;

@property (nullable, nonatomic, strong) void (^formBlock)(DLFormRowDescriptor * __nonnull sender);
@property (nullable, nonatomic) SEL formSelector;
@property (nullable, nonatomic, strong) NSString * formSegueIdenfifier DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("Use formSegueIdentifier instead");
@property (nullable, nonatomic, strong) NSString * formSegueIdentifier;
@property (nullable, nonatomic, strong) Class formSegueClass;

@end
