//
//  DLFormDescriptor.h
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

#import "DLFormSectionDescriptor.h"
#import "DLFormRowDescriptor.h"
#import "DLFormDescriptorDelegate.h"
#import <Foundation/Foundation.h>

extern NSString * __nonnull const DLFormErrorDomain;
extern NSString * __nonnull const DLValidationStatusErrorKey;

typedef NS_ENUM(NSInteger, DLFormErrorCode)
{
    DLFormErrorCodeGen = -999,
    DLFormErrorCodeRequired = -1000
};

typedef NS_OPTIONS(NSUInteger, DLFormRowNavigationOptions) {
    DLFormRowNavigationOptionNone                               = 0,
    DLFormRowNavigationOptionEnabled                            = 1 << 0,
    DLFormRowNavigationOptionStopDisableRow                     = 1 << 1,
    DLFormRowNavigationOptionSkipCanNotBecomeFirstResponderRow  = 1 << 2,
    DLFormRowNavigationOptionStopInlineRow                      = 1 << 3,
};

@class DLFormSectionDescriptor;

@interface DLFormDescriptor : NSObject

@property (readonly, nonatomic, nonnull) NSMutableArray * formSections;
@property (readonly, nullable) NSString * title;
@property (nonatomic) BOOL endEditingTableViewOnScroll;
@property (nonatomic) BOOL assignFirstResponderOnShow;
@property (nonatomic) BOOL addAsteriskToRequiredRowsTitle;
@property (getter=isDisabled) BOOL disabled;
@property (nonatomic) DLFormRowNavigationOptions rowNavigationOptions;

@property (weak, nullable) id<DLFormDescriptorDelegate> delegate;

+(nonnull instancetype)formDescriptor;
+(nonnull instancetype)formDescriptorWithTitle:(nullable NSString *)title;

-(void)addFormSection:(nonnull DLFormSectionDescriptor *)formSection;
-(void)addFormSection:(nonnull DLFormSectionDescriptor *)formSection atIndex:(NSUInteger)index;
-(void)addFormSection:(nonnull DLFormSectionDescriptor *)formSection afterSection:(nonnull DLFormSectionDescriptor *)afterSection;
-(void)addFormRow:(nonnull DLFormRowDescriptor *)formRow beforeRow:(nonnull DLFormRowDescriptor *)afterRow;
-(void)addFormRow:(nonnull DLFormRowDescriptor *)formRow beforeRowTag:(nonnull NSString *)afterRowTag;
-(void)addFormRow:(nonnull DLFormRowDescriptor *)formRow afterRow:(nonnull DLFormRowDescriptor *)afterRow;
-(void)addFormRow:(nonnull DLFormRowDescriptor *)formRow afterRowTag:(nonnull NSString *)afterRowTag;
-(void)removeFormSectionAtIndex:(NSUInteger)index;
-(void)removeFormSection:(nonnull DLFormSectionDescriptor *)formSection;
-(void)removeFormRow:(nonnull DLFormRowDescriptor *)formRow;
-(void)removeFormRowWithTag:(nonnull NSString *)tag;

-(nullable DLFormRowDescriptor *)formRowWithTag:(nonnull NSString *)tag;
-(nullable DLFormRowDescriptor *)formRowAtIndex:(nonnull NSIndexPath *)indexPath;
-(nullable DLFormRowDescriptor *)formRowWithHash:(NSUInteger)hash;
-(nullable DLFormSectionDescriptor *)formSectionAtIndex:(NSUInteger)index;

-(nullable NSIndexPath *)indexPathOfFormRow:(nonnull DLFormRowDescriptor *)formRow;

-(nonnull NSDictionary *)formValues;
-(nonnull NSDictionary *)httpParameters:(nonnull DLFormViewController *)formViewController;

-(nonnull NSArray *)localValidationErrors:(nonnull DLFormViewController *)formViewController;
-(void)setFirstResponder:(nonnull DLFormViewController *)formViewController;

-(nullable DLFormRowDescriptor *)nextRowDescriptorForRow:(nonnull DLFormRowDescriptor *)currentRow;
-(nullable DLFormRowDescriptor *)previousRowDescriptorForRow:(nonnull DLFormRowDescriptor *)currentRow;

-(void)forceEvaluate;

@end
