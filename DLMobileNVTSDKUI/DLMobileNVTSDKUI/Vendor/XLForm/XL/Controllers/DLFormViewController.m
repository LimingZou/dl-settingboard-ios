//
//  DLFormViewController.m
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

#import "UIView+DLFormAdditions.h"
#import "NSObject+DLFormAdditions.h"
#import "DLFormViewController.h"
#import "UIView+DLFormAdditions.h"
#import "DLForm.h"
#import "NSString+DLFormAdditions.h"


@interface DLFormRowDescriptor(_DLFormViewController)

@property (readonly) NSArray * observers;
-(BOOL)evaluateIsDisabled;
-(BOOL)evaluateIsHidden;

@end

@interface DLFormSectionDescriptor(_DLFormViewController)

-(BOOL)evaluateIsHidden;

@end

@interface DLFormDescriptor (_DLFormViewController)

@property NSMutableDictionary* rowObservers;

@end


@interface DLFormViewController()
{
    NSNumber *_oldBottomTableContentInset;
    CGRect _keyboardFrame;
}
@property UITableViewStyle tableViewStyle;
@property (nonatomic) DLFormRowNavigationAccessoryView * navigationAccessoryView;

@end

@implementation DLFormViewController

@synthesize form = _form;

#pragma mark - Initialization

-(instancetype)initWithForm:(DLFormDescriptor *)form
{
    return [self initWithForm:form style:UITableViewStyleGrouped];
}

-(instancetype)initWithForm:(DLFormDescriptor *)form style:(UITableViewStyle)style
{
    self = [self initWithNibName:nil bundle:nil];
    if (self){
        _tableViewStyle = style;
        _form = form;
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        _form = nil;
        _tableViewStyle = UITableViewStyleGrouped;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _form = nil;
        _tableViewStyle = UITableViewStyleGrouped;
    }
    
    return self;
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.tableView){
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                      style:self.tableViewStyle];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]){
            self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
    }
    if (!self.tableView.superview){
        [self.view addSubview:self.tableView];
    }
    if (!self.tableView.delegate){
        self.tableView.delegate = self;
    }
    if (!self.tableView.dataSource){
        self.tableView.dataSource = self;
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
    }
    if (self.form.title){
        self.title = self.form.title;
    }
    [self.tableView setEditing:YES animated:NO];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.form.delegate = self;
    _oldBottomTableContentInset = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    if (selected){
        // Trigger a cell refresh
        DLFormRowDescriptor * rowDescriptor = [self.form formRowAtIndex:selected];
        [self updateFormRow:rowDescriptor];
        [self.tableView selectRowAtIndexPath:selected animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.tableView deselectRowAtIndexPath:selected animated:YES];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.form.assignFirstResponderOnShow) {
        self.form.assignFirstResponderOnShow = NO;
        [self.form setFirstResponder:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - CellClasses

+(NSMutableDictionary *)cellClassesForRowDescriptorTypes
{
    static NSMutableDictionary * _cellClassesForRowDescriptorTypes;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cellClassesForRowDescriptorTypes = [@{DLFormRowDescriptorTypeText:[DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypeName: [DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypePhone:[DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypeURL:[DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypeEmail: [DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypeTwitter: [DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypeAccount: [DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypePassword: [DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypeNumber: [DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypeInteger: [DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypeDecimal: [DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypeZipCode: [DLFormTextFieldCell class],
                                               DLFormRowDescriptorTypeSelectorPush: [DLFormSelectorCell class],
                                               DLFormRowDescriptorTypeSelectorPopover: [DLFormSelectorCell class],
                                               DLFormRowDescriptorTypeSelectorActionSheet: [DLFormSelectorCell class],
                                               DLFormRowDescriptorTypeSelectorAlertView: [DLFormSelectorCell class],
                                               DLFormRowDescriptorTypeSelectorPickerView: [DLFormSelectorCell class],
                                               DLFormRowDescriptorTypeSelectorPickerViewInline: [DLFormInlineSelectorCell class],
                                               DLFormRowDescriptorTypeSelectorSegmentedControl: [DLFormSegmentedCell class],
                                               DLFormRowDescriptorTypeMultipleSelector: [DLFormSelectorCell class],
                                               DLFormRowDescriptorTypeMultipleSelectorPopover: [DLFormSelectorCell class],
                                               DLFormRowDescriptorTypeImage: [DLFormImageCell class],
                                               DLFormRowDescriptorTypeTextView: [DLFormTextViewCell class],
                                               DLFormRowDescriptorTypeButton: [DLFormButtonCell class],
                                               DLFormRowDescriptorTypeInfo: [DLFormSelectorCell class],
                                               DLFormRowDescriptorTypeBooleanSwitch : [DLFormSwitchCell class],
                                               DLFormRowDescriptorTypeBooleanCheck : [DLFormCheckCell class],
                                               DLFormRowDescriptorTypeDate: [DLFormDateCell class],
                                               DLFormRowDescriptorTypeTime: [DLFormDateCell class],
                                               DLFormRowDescriptorTypeDateTime : [DLFormDateCell class],
                                               DLFormRowDescriptorTypeCountDownTimer : [DLFormDateCell class],
                                               DLFormRowDescriptorTypeDateInline: [DLFormDateCell class],
                                               DLFormRowDescriptorTypeTimeInline: [DLFormDateCell class],
                                               DLFormRowDescriptorTypeDateTimeInline: [DLFormDateCell class],
                                               DLFormRowDescriptorTypeCountDownTimerInline : [DLFormDateCell class],
                                               DLFormRowDescriptorTypeDatePicker : [DLFormDatePickerCell class],
                                               DLFormRowDescriptorTypePicker : [DLFormPickerCell class],
                                               DLFormRowDescriptorTypeSlider : [DLFormSliderCell class],
                                               DLFormRowDescriptorTypeSelectorLeftRight : [DLFormLeftRightSelectorCell class],
                                               DLFormRowDescriptorTypeStepCounter: [DLFormStepCounterCell class]
                                               } mutableCopy];
    });
    return _cellClassesForRowDescriptorTypes;
}

#pragma mark - inlineRowDescriptorTypes

+(NSMutableDictionary *)inlineRowDescriptorTypesForRowDescriptorTypes
{
    static NSMutableDictionary * _inlineRowDescriptorTypesForRowDescriptorTypes;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inlineRowDescriptorTypesForRowDescriptorTypes = [
                                                          @{DLFormRowDescriptorTypeSelectorPickerViewInline: DLFormRowDescriptorTypePicker,
                                                            DLFormRowDescriptorTypeDateInline: DLFormRowDescriptorTypeDatePicker,
                                                            DLFormRowDescriptorTypeDateTimeInline: DLFormRowDescriptorTypeDatePicker,
                                                            DLFormRowDescriptorTypeTimeInline: DLFormRowDescriptorTypeDatePicker,
                                                            DLFormRowDescriptorTypeCountDownTimerInline: DLFormRowDescriptorTypeDatePicker
                                                            } mutableCopy];
    });
    return _inlineRowDescriptorTypesForRowDescriptorTypes;
}

#pragma mark - DLFormDescriptorDelegate

-(void)formRowHasBeenAdded:(DLFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:[self insertRowAnimationForRow:formRow]];
    [self.tableView endUpdates];
}

-(void)formRowHasBeenRemoved:(DLFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:[self deleteRowAnimationForRow:formRow]];
    [self.tableView endUpdates];
}

-(void)formSectionHasBeenRemoved:(DLFormSectionDescriptor *)formSection atIndex:(NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:[self deleteRowAnimationForSection:formSection]];
    [self.tableView endUpdates];
}

-(void)formSectionHasBeenAdded:(DLFormSectionDescriptor *)formSection atIndex:(NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:[self insertRowAnimationForSection:formSection]];
    [self.tableView endUpdates];
}

-(void)formRowDescriptorValueHasChanged:(DLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    [self updateAfterDependentRowChanged:formRow];
}

-(void)formRowDescriptorPredicateHasChanged:(DLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue predicateType:(XLPredicateType)predicateType
{
    if (oldValue != newValue) {
        [self updateAfterDependentRowChanged:formRow];
    }
}

-(void)updateAfterDependentRowChanged:(DLFormRowDescriptor *)formRow
{
    NSMutableArray* revaluateHidden   = self.form.rowObservers[[formRow.tag formKeyForPredicateType:XLPredicateTypeHidden]];
    NSMutableArray* revaluateDisabled = self.form.rowObservers[[formRow.tag formKeyForPredicateType:XLPredicateTypeDisabled]];
    for (id object in revaluateDisabled) {
        if ([object isKindOfClass:[NSString class]]) {
            DLFormRowDescriptor* row = [self.form formRowWithTag:object];
            if (row){
                [row evaluateIsDisabled];
                [self updateFormRow:row];
            }
        }
    }
    for (id object in revaluateHidden) {
        if ([object isKindOfClass:[NSString class]]) {
            DLFormRowDescriptor* row = [self.form formRowWithTag:object];
            if (row){
                [row evaluateIsHidden];
            }
        }
        else if ([object isKindOfClass:[DLFormSectionDescriptor class]]) {
            DLFormSectionDescriptor* section = (DLFormSectionDescriptor*) object;
            [section evaluateIsHidden];
        }
    }
}

#pragma mark - DLFormViewControllerDelegate

-(NSDictionary *)formValues
{
    return [self.form formValues];
}

-(NSDictionary *)httpParameters
{
    return [self.form httpParameters:self];
}


-(void)didSelectFormRow:(DLFormRowDescriptor *)formRow
{
    if ([[formRow cellForFormController:self] respondsToSelector:@selector(formDescriptorCellDidSelectedWithFormController:)]){
        [[formRow cellForFormController:self] formDescriptorCellDidSelectedWithFormController:self];
    }
}

-(UITableViewRowAnimation)insertRowAnimationForRow:(DLFormRowDescriptor *)formRow
{
    if (formRow.sectionDescriptor.sectionOptions & DLFormSectionOptionCanInsert){
        if (formRow.sectionDescriptor.sectionInsertMode == DLFormSectionInsertModeButton){
            return UITableViewRowAnimationAutomatic;
        }
        else if (formRow.sectionDescriptor.sectionInsertMode == DLFormSectionInsertModeLastRow){
            return YES;
        }
    }
    return UITableViewRowAnimationFade;
}

-(UITableViewRowAnimation)deleteRowAnimationForRow:(DLFormRowDescriptor *)formRow
{
    return UITableViewRowAnimationFade;
}

-(UITableViewRowAnimation)insertRowAnimationForSection:(DLFormSectionDescriptor *)formSection
{
    return UITableViewRowAnimationAutomatic;
}

-(UITableViewRowAnimation)deleteRowAnimationForSection:(DLFormSectionDescriptor *)formSection
{
    return UITableViewRowAnimationAutomatic;
}

-(UIView *)inputAccessoryViewForRowDescriptor:(DLFormRowDescriptor *)rowDescriptor
{
    if ((self.form.rowNavigationOptions & DLFormRowNavigationOptionEnabled) != DLFormRowNavigationOptionEnabled){
        return nil;
    }
    if ([[[[self class] inlineRowDescriptorTypesForRowDescriptorTypes] allKeys] containsObject:rowDescriptor.rowType]) {
        return nil;
    }
    UITableViewCell<DLFormDescriptorCell> * cell = (UITableViewCell<DLFormDescriptorCell> *)[rowDescriptor cellForFormController:self];
    if (![cell formDescriptorCellCanBecomeFirstResponder]){
        return nil;
    }
    DLFormRowDescriptor * previousRow = [self nextRowDescriptorForRow:rowDescriptor
                                                            withDirection:DLFormRowNavigationDirectionPrevious];
    DLFormRowDescriptor * nextRow     = [self nextRowDescriptorForRow:rowDescriptor
                                                            withDirection:DLFormRowNavigationDirectionNext];
    [self.navigationAccessoryView.previousButton setEnabled:(previousRow != nil)];
    [self.navigationAccessoryView.nextButton setEnabled:(nextRow != nil)];
    return self.navigationAccessoryView;
}

-(void)beginEditing:(DLFormRowDescriptor *)rowDescriptor
{
    [[rowDescriptor cellForFormController:self] highlight];
}

-(void)endEditing:(DLFormRowDescriptor *)rowDescriptor
{
    [[rowDescriptor cellForFormController:self] unhighlight];
}

-(DLFormRowDescriptor *)formRowFormMultivaluedFormSection:(DLFormSectionDescriptor *)formSection
{
    if (formSection.multivaluedRowTemplate){
        return [formSection.multivaluedRowTemplate copy];
    }
    DLFormRowDescriptor * formRowDescriptor = [[formSection.formRows objectAtIndex:0] copy];
    formRowDescriptor.tag = nil;
    return formRowDescriptor;
}

-(void)multivaluedInsertButtonTapped:(DLFormRowDescriptor *)formRow
{
    [self deselectFormRow:formRow];
    DLFormSectionDescriptor * multivaluedFormSection = formRow.sectionDescriptor;
    DLFormRowDescriptor * formRowDescriptor = [self formRowFormMultivaluedFormSection:multivaluedFormSection];
    [multivaluedFormSection addFormRow:formRowDescriptor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableView.editing = !self.tableView.editing;
        self.tableView.editing = !self.tableView.editing;
    });
    UITableViewCell<DLFormDescriptorCell> * cell = (UITableViewCell<DLFormDescriptorCell> *)[formRowDescriptor cellForFormController:self];
    if ([cell formDescriptorCellCanBecomeFirstResponder]){
        [cell formDescriptorCellBecomeFirstResponder];
    }
}

-(void)ensureRowIsVisible:(DLFormRowDescriptor *)inlineRowDescriptor
{
    DLFormBaseCell * inlineCell = [inlineRowDescriptor cellForFormController:self];
    NSIndexPath * indexOfOutOfWindowCell = [self.form indexPathOfFormRow:inlineRowDescriptor];
    if(!inlineCell.window || (self.tableView.contentOffset.y + self.tableView.frame.size.height <= inlineCell.frame.origin.y + inlineCell.frame.size.height)){
        [self.tableView scrollToRowAtIndexPath:indexOfOutOfWindowCell atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Methods

-(NSArray *)formValidationErrors
{
    return [self.form localValidationErrors:self];
}

-(void)showFormValidationError:(NSError *)error
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                         message:error.localizedFailureReason
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                               otherButtonTitles:nil];
    [alertView show];
#else
    if ([UIAlertController class]){
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                                                  message:error.localizedFailureReason
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:error.localizedRecoverySuggestion
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
#ifndef XL_APP_EXTENSIONS
    else{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                             message:error.localizedFailureReason
                                                            delegate:self
                                                   cancelButtonTitle:error.localizedRecoverySuggestion
                                                   otherButtonTitles:nil];
        [alertView show];
    }
#endif
#endif
}

-(void)showFormValidationError:(NSError *)error withTitle:(NSString*)title
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
                                                         message:error.localizedDescription
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                               otherButtonTitles:nil];
    [alertView show];
#else
    if ([UIAlertController class]){
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(title, nil)
                                                                                  message:error.localizedDescription
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
#ifndef XL_APP_EXTENSIONS
    else{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
                                                             message:error.localizedDescription
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                   otherButtonTitles:nil];
        [alertView show];
    }
#endif
#endif
}

-(void)performFormSelector:(SEL)selector withObject:(id)sender
{
    UIResponder * responder = [self targetForAction:selector withSender:sender];;
    if (responder) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Warc-performSelector-leaks"
        [responder performSelector:selector withObject:sender];
#pragma GCC diagnostic pop
    }
}

#pragma mark - Private

- (void)contentSizeCategoryChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    UIView * firstResponderView = [self.tableView findFirstResponder];
    UITableViewCell<DLFormDescriptorCell> * cell = [firstResponderView formDescriptorCell];
    if (cell){
        NSDictionary *keyboardInfo = [notification userInfo];
        _keyboardFrame = [self.tableView.window convertRect:[keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.tableView.superview];
        CGFloat newBottomInset = self.tableView.frame.origin.y + self.tableView.frame.size.height - _keyboardFrame.origin.y;
        UIEdgeInsets tableContentInset = self.tableView.contentInset;
        UIEdgeInsets tableScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        _oldBottomTableContentInset = _oldBottomTableContentInset ?: @(tableContentInset.bottom);
        if (newBottomInset > [_oldBottomTableContentInset floatValue]){
            tableContentInset.bottom = newBottomInset;
            tableScrollIndicatorInsets.bottom = tableContentInset.bottom;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:[keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
            [UIView setAnimationCurve:[keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
            self.tableView.contentInset = tableContentInset;
            self.tableView.scrollIndicatorInsets = tableScrollIndicatorInsets;
            NSIndexPath *selectedRow = [self.tableView indexPathForCell:cell];
            [self.tableView scrollToRowAtIndexPath:selectedRow atScrollPosition:UITableViewScrollPositionNone animated:NO];
            [UIView commitAnimations];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIView * firstResponderView = [self.tableView findFirstResponder];
    UITableViewCell<DLFormDescriptorCell> * cell = [firstResponderView formDescriptorCell];
    if (cell){
        _keyboardFrame = CGRectZero;
        NSDictionary *keyboardInfo = [notification userInfo];
        UIEdgeInsets tableContentInset = self.tableView.contentInset;
        UIEdgeInsets tableScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        tableContentInset.bottom = [_oldBottomTableContentInset floatValue];
        tableScrollIndicatorInsets.bottom = tableContentInset.bottom;
        _oldBottomTableContentInset = nil;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:[keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
        self.tableView.contentInset = tableContentInset;
        self.tableView.scrollIndicatorInsets = tableScrollIndicatorInsets;
        [UIView commitAnimations];
    }
}

#pragma mark - Helpers

-(void)deselectFormRow:(DLFormRowDescriptor *)formRow
{
    NSIndexPath * indexPath = [self.form indexPathOfFormRow:formRow];
    if (indexPath){
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)reloadFormRow:(DLFormRowDescriptor *)formRow
{
    NSIndexPath * indexPath = [self.form indexPathOfFormRow:formRow];
    if (indexPath){
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(DLFormBaseCell *)updateFormRow:(DLFormRowDescriptor *)formRow
{
    DLFormBaseCell * cell = [formRow cellForFormController:self];
    [self configureCell:cell];
    [cell setNeedsUpdateConstraints];
    [cell setNeedsLayout];
    return cell;
}

-(void)configureCell:(DLFormBaseCell*) cell
{
    [cell update];
    [cell.rowDescriptor.cellConfig enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, id value, BOOL * __unused stop) {
        [cell setValue:(value == [NSNull null]) ? nil : value forKeyPath:keyPath];
    }];
    if (cell.rowDescriptor.isDisabled){
        [cell.rowDescriptor.cellConfigIfDisabled enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, id value, BOOL * __unused stop) {
            [cell setValue:(value == [NSNull null]) ? nil : value forKeyPath:keyPath];
        }];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.form.formSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section >= self.form.formSections.count){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil];
    }
    return [[[self.form.formSections objectAtIndex:section] formRows] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLFormRowDescriptor * rowDescriptor = [self.form formRowAtIndex:indexPath];
    [self updateFormRow:rowDescriptor];
    return [rowDescriptor cellForFormController:self];
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    if (rowDescriptor.isDisabled || !rowDescriptor.sectionDescriptor.isMultivaluedSection){
        return NO;
    }
    DLFormBaseCell * baseCell = [rowDescriptor cellForFormController:self];
    if ([baseCell conformsToProtocol:@protocol(DLFormInlineRowDescriptorCell)] && ((id<DLFormInlineRowDescriptorCell>)baseCell).inlineRowDescriptor){
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    DLFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    DLFormSectionDescriptor * section = rowDescriptor.sectionDescriptor;
    if (section.sectionOptions & DLFormSectionOptionCanReorder && section.formRows.count > 1) {
        if (section.sectionInsertMode == DLFormSectionInsertModeButton && section.sectionOptions & DLFormSectionOptionCanInsert){
            if (section.formRows.count <= 2 || rowDescriptor == section.multivaluedAddButton){
                return NO;
            }
        }
        DLFormBaseCell * baseCell = [rowDescriptor cellForFormController:self];
        return !([baseCell conformsToProtocol:@protocol(DLFormInlineRowDescriptorCell)] && ((id<DLFormInlineRowDescriptorCell>)baseCell).inlineRowDescriptor);
    }
    return NO;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    DLFormRowDescriptor * row = [self.form formRowAtIndex:sourceIndexPath];
    DLFormSectionDescriptor * section = row.sectionDescriptor;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Warc-performSelector-leaks"
    [section performSelector:NSSelectorFromString(@"moveRowAtIndexPath:toIndexPath:") withObject:sourceIndexPath withObject:destinationIndexPath];
#pragma GCC diagnostic pop
    // update the accessory view
    [self inputAccessoryViewForRowDescriptor:row];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableView.editing = !self.tableView.editing;
        self.tableView.editing = !self.tableView.editing;
    });

}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        DLFormRowDescriptor * multivaluedFormRow = [self.form formRowAtIndex:indexPath];
        // end editing
        UIView * firstResponder = [[multivaluedFormRow cellForFormController:self] findFirstResponder];
        if (firstResponder){
                [self.tableView endEditing:YES];
        }
        [multivaluedFormRow.sectionDescriptor removeFormRowAtIndex:indexPath.row];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tableView.editing = !self.tableView.editing;
            self.tableView.editing = !self.tableView.editing;
        });
        if (firstResponder){
            UITableViewCell<DLFormDescriptorCell> * firstResponderCell = [firstResponder formDescriptorCell];
            DLFormRowDescriptor * rowDescriptor = firstResponderCell.rowDescriptor;
            [self inputAccessoryViewForRowDescriptor:rowDescriptor];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert){

        DLFormSectionDescriptor * multivaluedFormSection = [self.form formSectionAtIndex:indexPath.section];
        if (multivaluedFormSection.sectionInsertMode == DLFormSectionInsertModeButton && multivaluedFormSection.sectionOptions & DLFormSectionOptionCanInsert){
            [self multivaluedInsertButtonTapped:multivaluedFormSection.multivaluedAddButton];
        }
        else{
            DLFormRowDescriptor * formRowDescriptor = [self formRowFormMultivaluedFormSection:multivaluedFormSection];
            [multivaluedFormSection addFormRow:formRowDescriptor];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.tableView.editing = !self.tableView.editing;
                self.tableView.editing = !self.tableView.editing;
            });
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            UITableViewCell<DLFormDescriptorCell> * cell = (UITableViewCell<DLFormDescriptorCell> *)[formRowDescriptor cellForFormController:self];
            if ([cell formDescriptorCellCanBecomeFirstResponder]){
                [cell formDescriptorCellBecomeFirstResponder];
            }
        }
    }
}

#pragma mark - UITableViewDelegate

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.form.formSections objectAtIndex:section] title];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [[self.form.formSections objectAtIndex:section] footerTitle];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    [rowDescriptor cellForFormController:self];
    CGFloat height = rowDescriptor.height;
    if (height != DLFormUnspecifiedCellHeight){
        return height;
    }
    return self.tableView.rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    [rowDescriptor cellForFormController:self];
    CGFloat height = rowDescriptor.height;
    if (height != DLFormUnspecifiedCellHeight){
        return height;
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        return self.tableView.estimatedRowHeight;
    }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLFormRowDescriptor * row = [self.form formRowAtIndex:indexPath];
    if (row.isDisabled) {
        return;
    }
    UITableViewCell<DLFormDescriptorCell> * cell = (UITableViewCell<DLFormDescriptorCell> *)[row cellForFormController:self];
    if (!([cell formDescriptorCellCanBecomeFirstResponder] && [cell formDescriptorCellBecomeFirstResponder])){
        [self.tableView endEditing:YES];
    }
    [self didSelectFormRow:row];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLFormRowDescriptor * row = [self.form formRowAtIndex:indexPath];
    DLFormSectionDescriptor * section = row.sectionDescriptor;
    if (section.sectionOptions & DLFormSectionOptionCanInsert){
        if (section.formRows.count == indexPath.row + 2){
            if ([[DLFormViewController inlineRowDescriptorTypesForRowDescriptorTypes].allKeys containsObject:row.rowType]){
                UITableViewCell<DLFormDescriptorCell> * cell = [row cellForFormController:self];
                UIView * firstResponder = [cell findFirstResponder];
                if (firstResponder){
                    return UITableViewCellEditingStyleInsert;
                }
            }
        }
        else if (section.formRows.count == (indexPath.row + 1)){
            return UITableViewCellEditingStyleInsert;
        }
    }
    if (section.sectionOptions & DLFormSectionOptionCanDelete){
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        return sourceIndexPath;
    }
    DLFormSectionDescriptor * sectionDescriptor = [self.form formSectionAtIndex:sourceIndexPath.section];
    DLFormRowDescriptor * proposedDestination = [sectionDescriptor.formRows objectAtIndex:proposedDestinationIndexPath.row];
    DLFormBaseCell * proposedDestinationCell = [proposedDestination cellForFormController:self];
    if (([proposedDestinationCell conformsToProtocol:@protocol(DLFormInlineRowDescriptorCell)] && ((id<DLFormInlineRowDescriptorCell>)proposedDestinationCell).inlineRowDescriptor) || ([[DLFormViewController inlineRowDescriptorTypesForRowDescriptorTypes].allKeys containsObject:proposedDestinationCell.rowDescriptor.rowType] && [[proposedDestinationCell findFirstResponder] formDescriptorCell] == proposedDestinationCell)) {
        if (sourceIndexPath.row < proposedDestinationIndexPath.row){
            return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row + 1 inSection:sourceIndexPath.section];
        }
        else{
            return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row - 1 inSection:sourceIndexPath.section];
        }
    }

    if ((sectionDescriptor.sectionInsertMode == DLFormSectionInsertModeButton && sectionDescriptor.sectionOptions & DLFormSectionOptionCanInsert)){
        if (proposedDestinationIndexPath.row == sectionDescriptor.formRows.count - 1){
            return [NSIndexPath indexPathForRow:(sectionDescriptor.formRows.count - 2) inSection:sourceIndexPath.section];
        }
    }
    return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle editingStyle = [self tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleNone){
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView willBeginReorderingRowAtIndexPath:(NSIndexPath *)indexPath
{
    // end editing if inline cell is first responder
    UITableViewCell<DLFormDescriptorCell> * cell = [[self.tableView findFirstResponder] formDescriptorCell];
    if ([[self.form indexPathOfFormRow:cell.rowDescriptor] isEqual:indexPath]){
        if ([[DLFormViewController inlineRowDescriptorTypesForRowDescriptorTypes].allKeys containsObject:cell.rowDescriptor.rowType]){
            [self.tableView endEditing:YES];
        }
    }
}

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // called when 'return' key pressed. return NO to ignore.
    UITableViewCell<DLFormDescriptorCell> * cell = [textField formDescriptorCell];
    DLFormRowDescriptor * currentRow = cell.rowDescriptor;
    DLFormRowDescriptor * nextRow = [self nextRowDescriptorForRow:currentRow
                                                    withDirection:DLFormRowNavigationDirectionNext];
    if (nextRow){
        UITableViewCell<DLFormDescriptorCell> * nextCell = (UITableViewCell<DLFormDescriptorCell> *)[nextRow cellForFormController:self];
        if ([nextCell formDescriptorCellCanBecomeFirstResponder]){
            [nextCell formDescriptorCellBecomeFirstResponder];
            return YES;
        }
    }
    [self.tableView endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UITableViewCell<DLFormDescriptorCell>* cell = textField.formDescriptorCell;
    DLFormRowDescriptor * nextRow     = [self nextRowDescriptorForRow:textField.formDescriptorCell.rowDescriptor
                                                        withDirection:DLFormRowNavigationDirectionNext];
    
    
    if ([cell conformsToProtocol:@protocol(DLFormReturnKeyProtocol)]) {
        textField.returnKeyType = nextRow ? ((id<DLFormReturnKeyProtocol>)cell).nextReturnKeyType : ((id<DLFormReturnKeyProtocol>)cell).returnKeyType;
    }
    else {
        textField.returnKeyType = nextRow ? UIReturnKeyNext : UIReturnKeyDefault;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //dismiss keyboard
    if (NO == self.form.endEditingTableViewOnScroll) {
        return;
    }

    UIView * firstResponder = [self.tableView findFirstResponder];
    if ([firstResponder conformsToProtocol:@protocol(DLFormDescriptorCell)]){
        id<DLFormDescriptorCell> cell = (id<DLFormDescriptorCell>)firstResponder;
        if ([[DLFormViewController inlineRowDescriptorTypesForRowDescriptorTypes].allKeys containsObject:cell.rowDescriptor.rowType]){
            return;
        }
    }
    [self.tableView endEditing:YES];
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[DLFormRowDescriptor class]]){
        UIViewController * destinationViewController = segue.destinationViewController;
        DLFormRowDescriptor * rowDescriptor = (DLFormRowDescriptor *)sender;
        if (rowDescriptor.rowType == DLFormRowDescriptorTypeSelectorPush || rowDescriptor.rowType == DLFormRowDescriptorTypeSelectorPopover){
            NSAssert([destinationViewController conformsToProtocol:@protocol(DLFormRowDescriptorViewController)], @"Segue destinationViewController must conform to DLFormRowDescriptorViewController protocol");
            UIViewController<DLFormRowDescriptorViewController> * rowDescriptorViewController = (UIViewController<DLFormRowDescriptorViewController> *)destinationViewController;
            rowDescriptorViewController.rowDescriptor = rowDescriptor;
        }
        else if ([destinationViewController conformsToProtocol:@protocol(DLFormRowDescriptorViewController)]){
            UIViewController<DLFormRowDescriptorViewController> * rowDescriptorViewController = (UIViewController<DLFormRowDescriptorViewController> *)destinationViewController;
            rowDescriptorViewController.rowDescriptor = rowDescriptor;
        }
    }
}

#pragma mark - Navigation Between Fields


-(void)rowNavigationAction:(UIBarButtonItem *)sender
{
    [self navigateToDirection:(sender == self.navigationAccessoryView.nextButton ? DLFormRowNavigationDirectionNext : DLFormRowNavigationDirectionPrevious)];
}

-(void)rowNavigationDone:(UIBarButtonItem *)sender
{
    [self.tableView endEditing:YES];
}

-(void)navigateToDirection:(DLFormRowNavigationDirection)direction
{
    UIView * firstResponder = [self.tableView findFirstResponder];
    UITableViewCell<DLFormDescriptorCell> * currentCell = [firstResponder formDescriptorCell];
    NSIndexPath * currentIndexPath = [self.tableView indexPathForCell:currentCell];
    DLFormRowDescriptor * currentRow = [self.form formRowAtIndex:currentIndexPath];
    DLFormRowDescriptor * nextRow = [self nextRowDescriptorForRow:currentRow withDirection:direction];
    if (nextRow) {
        UITableViewCell<DLFormDescriptorCell> * cell = (UITableViewCell<DLFormDescriptorCell> *)[nextRow cellForFormController:self];
        if ([cell formDescriptorCellCanBecomeFirstResponder]){
            NSIndexPath * indexPath = [self.form indexPathOfFormRow:nextRow];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
            [cell formDescriptorCellBecomeFirstResponder];
        }
    }
}

-(DLFormRowDescriptor *)nextRowDescriptorForRow:(DLFormRowDescriptor*)currentRow withDirection:(DLFormRowNavigationDirection)direction
{
    if (!currentRow || (self.form.rowNavigationOptions & DLFormRowNavigationOptionEnabled) != DLFormRowNavigationOptionEnabled) {
        return nil;
    }
    DLFormRowDescriptor * nextRow = (direction == DLFormRowNavigationDirectionNext) ? [self.form nextRowDescriptorForRow:currentRow] : [self.form previousRowDescriptorForRow:currentRow];
    if (!nextRow) {
        return nil;
    }
    if ([[nextRow cellForFormController:self] conformsToProtocol:@protocol(DLFormInlineRowDescriptorCell)]) {
        id<DLFormInlineRowDescriptorCell> inlineCell = (id<DLFormInlineRowDescriptorCell>)[nextRow cellForFormController:self];
        if (inlineCell.inlineRowDescriptor){
            return [self nextRowDescriptorForRow:nextRow withDirection:direction];
        }
    }
    DLFormRowNavigationOptions rowNavigationOptions = self.form.rowNavigationOptions;
    if (nextRow.isDisabled && ((rowNavigationOptions & DLFormRowNavigationOptionStopDisableRow) == DLFormRowNavigationOptionStopDisableRow)){
        return nil;
    }
    if (!nextRow.isDisabled && ((rowNavigationOptions & DLFormRowNavigationOptionStopInlineRow) == DLFormRowNavigationOptionStopInlineRow) && [[[DLFormViewController inlineRowDescriptorTypesForRowDescriptorTypes] allKeys] containsObject:nextRow.rowType]){
        return nil;
    }
    UITableViewCell<DLFormDescriptorCell> * cell = (UITableViewCell<DLFormDescriptorCell> *)[nextRow cellForFormController:self];
    if (!nextRow.isDisabled && ((rowNavigationOptions & DLFormRowNavigationOptionSkipCanNotBecomeFirstResponderRow) != DLFormRowNavigationOptionSkipCanNotBecomeFirstResponderRow) && (![cell formDescriptorCellCanBecomeFirstResponder])){
        return nil;
    }
    if (!nextRow.isDisabled && [cell formDescriptorCellCanBecomeFirstResponder]){
        return nextRow;
    }
    return [self nextRowDescriptorForRow:nextRow withDirection:direction];
}

#pragma mark - properties

-(void)setForm:(DLFormDescriptor *)form
{
    _form.delegate = nil;
    [self.tableView endEditing:YES];
    _form = form;
    _form.delegate = self;
    [_form forceEvaluate];
    if ([self isViewLoaded]){
        [self.tableView reloadData];
    }
}

-(DLFormDescriptor *)form
{
    return _form;
}

-(DLFormRowNavigationAccessoryView *)navigationAccessoryView
{
    if (_navigationAccessoryView) return _navigationAccessoryView;
    _navigationAccessoryView = [DLFormRowNavigationAccessoryView new];
    _navigationAccessoryView.previousButton.target = self;
    _navigationAccessoryView.previousButton.action = @selector(rowNavigationAction:);
    _navigationAccessoryView.nextButton.target = self;
    _navigationAccessoryView.nextButton.action = @selector(rowNavigationAction:);
    _navigationAccessoryView.doneButton.target = self;
    _navigationAccessoryView.doneButton.action = @selector(rowNavigationDone:);
    _navigationAccessoryView.tintColor = self.view.tintColor;
    return _navigationAccessoryView;
}

@end

