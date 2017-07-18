//
//  DLFormViewController.h
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

#import <UIKit/UIKit.h>
#import "DLFormOptionsViewController.h"
#import "DLFormDescriptor.h"
#import "DLFormSectionDescriptor.h"
#import "DLFormDescriptorDelegate.h"
#import "DLFormRowNavigationAccessoryView.h"
#import "DLFormBaseCell.h"

@class DLFormViewController;
@class DLFormRowDescriptor;
@class DLFormSectionDescriptor;
@class DLFormDescriptor;
@class DLFormBaseCell;

typedef NS_ENUM(NSUInteger, DLFormRowNavigationDirection) {
    DLFormRowNavigationDirectionPrevious = 0,
    DLFormRowNavigationDirectionNext
};

@protocol DLFormViewControllerDelegate <NSObject>

@optional

-(void)didSelectFormRow:(DLFormRowDescriptor *)formRow;
-(void)deselectFormRow:(DLFormRowDescriptor *)formRow;
-(void)reloadFormRow:(DLFormRowDescriptor *)formRow;
-(DLFormBaseCell *)updateFormRow:(DLFormRowDescriptor *)formRow;

-(NSDictionary *)formValues;
-(NSDictionary *)httpParameters;

-(DLFormRowDescriptor *)formRowFormMultivaluedFormSection:(DLFormSectionDescriptor *)formSection;
-(void)multivaluedInsertButtonTapped:(DLFormRowDescriptor *)formRow;
-(UIStoryboard *)storyboardForRow:(DLFormRowDescriptor *)formRow;

-(NSArray *)formValidationErrors;
-(void)showFormValidationError:(NSError *)error;
-(void)showFormValidationError:(NSError *)error withTitle:(NSString*)title;

-(UITableViewRowAnimation)insertRowAnimationForRow:(DLFormRowDescriptor *)formRow;
-(UITableViewRowAnimation)deleteRowAnimationForRow:(DLFormRowDescriptor *)formRow;
-(UITableViewRowAnimation)insertRowAnimationForSection:(DLFormSectionDescriptor *)formSection;
-(UITableViewRowAnimation)deleteRowAnimationForSection:(DLFormSectionDescriptor *)formSection;

// InputAccessoryView
-(UIView *)inputAccessoryViewForRowDescriptor:(DLFormRowDescriptor *)rowDescriptor;
-(DLFormRowDescriptor *)nextRowDescriptorForRow:(DLFormRowDescriptor*)currentRow withDirection:(DLFormRowNavigationDirection)direction;

// highlight/unhighlight
-(void)beginEditing:(DLFormRowDescriptor *)rowDescriptor;
-(void)endEditing:(DLFormRowDescriptor *)rowDescriptor;

-(void)ensureRowIsVisible:(DLFormRowDescriptor *)inlineRowDescriptor;

@end

@interface DLFormViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DLFormDescriptorDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, DLFormViewControllerDelegate>

@property DLFormDescriptor * form;
@property IBOutlet UITableView * tableView;

-(instancetype)initWithForm:(DLFormDescriptor *)form;
-(instancetype)initWithForm:(DLFormDescriptor *)form style:(UITableViewStyle)style;
-(instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;
+(NSMutableDictionary *)cellClassesForRowDescriptorTypes;
+(NSMutableDictionary *)inlineRowDescriptorTypesForRowDescriptorTypes;

-(void)performFormSelector:(SEL)selector withObject:(id)sender;

@end
