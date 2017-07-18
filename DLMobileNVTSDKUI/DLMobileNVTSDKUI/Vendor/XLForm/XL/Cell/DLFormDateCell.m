//
//  DLFormDateCell.m
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
#import "DLFormRowDescriptor.h"
#import "DLFormDateCell.h"

@interface DLFormDateCell()

@property (nonatomic) UIDatePicker *datePicker;

@end

@implementation DLFormDateCell
{
    UIColor * _beforeChangeColor;
    NSDateFormatter *_dateFormatter;
}


- (UIView *)inputView
{
    if ([self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDateTime] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeCountDownTimer]){
        if (self.rowDescriptor.value){
            [self.datePicker setDate:self.rowDescriptor.value animated:[self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeCountDownTimer]];
        }
        [self setModeToDatePicker:self.datePicker];
        return self.datePicker;
    }
    return [super inputView];
}

- (BOOL)canBecomeFirstResponder
{
    return !self.rowDescriptor.isDisabled;
}

-(BOOL)becomeFirstResponder
{
    if (self.isFirstResponder){
        return [super becomeFirstResponder];
    }
    _beforeChangeColor = self.detailTextLabel.textColor;
    BOOL result = [super becomeFirstResponder];
    if (result){
        if ([self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDateTimeInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeCountDownTimerInline])
        {
            NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
            NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:(selectedRowPath.row + 1) inSection:selectedRowPath.section];
            DLFormSectionDescriptor * formSection = [self.formViewController.form.formSections objectAtIndex:nextRowPath.section];
            DLFormRowDescriptor * datePickerRowDescriptor = [DLFormRowDescriptor formRowDescriptorWithTag:nil rowType:DLFormRowDescriptorTypeDatePicker];
            DLFormDatePickerCell * datePickerCell = (DLFormDatePickerCell *)[datePickerRowDescriptor cellForFormController:self.formViewController];
            [self setModeToDatePicker:datePickerCell.datePicker];
            if (self.rowDescriptor.value){                
                [datePickerCell.datePicker setDate:self.rowDescriptor.value animated:[self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeCountDownTimerInline]];
            }
            NSAssert([datePickerCell conformsToProtocol:@protocol(DLFormInlineRowDescriptorCell)], @"inline cell must conform to DLFormInlineRowDescriptorCell");
            UITableViewCell<DLFormInlineRowDescriptorCell> * inlineCell = (UITableViewCell<DLFormInlineRowDescriptorCell> *)datePickerCell;
            inlineCell.inlineRowDescriptor = self.rowDescriptor;
            
            [formSection addFormRow:datePickerRowDescriptor afterRow:self.rowDescriptor];
            [self.formViewController ensureRowIsVisible:datePickerRowDescriptor];
        }
    }
    return result;
}

-(BOOL)resignFirstResponder
{
    if ([self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDateTimeInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeCountDownTimerInline])
    {
        NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
        NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
        DLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
        BOOL result = [super resignFirstResponder];
        if ([nextFormRow.rowType isEqualToString:DLFormRowDescriptorTypeDatePicker]){
            [self.rowDescriptor.sectionDescriptor removeFormRow:nextFormRow];
        }
        return result;
    }
    return [super resignFirstResponder];
}

#pragma mark - DLFormDescriptorCell

-(void)configure
{
    [super configure];
    self.formDatePickerMode = DLFormDateDatePickerModeGetFromRowDescriptor;
    _dateFormatter = [[NSDateFormatter alloc] init];
}

-(void)update
{
    [super update];
    self.accessoryType =  UITableViewCellAccessoryNone;
    self.editingAccessoryType =  UITableViewCellAccessoryNone;
    [self.textLabel setText:self.rowDescriptor.title];
    self.selectionStyle = self.rowDescriptor.isDisabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    self.textLabel.text = [NSString stringWithFormat:@"%@%@", self.rowDescriptor.title, self.rowDescriptor.required && self.rowDescriptor.sectionDescriptor.formDescriptor.addAsteriskToRequiredRowsTitle ? @"*" : @""];
    self.detailTextLabel.text = [self valueDisplayText];
}

-(void)formDescriptorCellDidSelectedWithFormController:(DLFormViewController *)controller
{
    [self.formViewController.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
}

-(BOOL)formDescriptorCellCanBecomeFirstResponder
{
    return [self canBecomeFirstResponder];
}

-(BOOL)formDescriptorCellBecomeFirstResponder
{
    if ([self isFirstResponder]){
        return [self resignFirstResponder];
    }
    return [self becomeFirstResponder];

}

-(void)highlight
{
    [super highlight];
    self.detailTextLabel.textColor = self.tintColor;
}

-(void)unhighlight
{
    [super unhighlight];
    self.detailTextLabel.textColor = _beforeChangeColor;
}


#pragma mark - helpers

-(NSString *)valueDisplayText
{
    return self.rowDescriptor.value ? [self formattedDate:self.rowDescriptor.value] : self.rowDescriptor.noValueDisplayText;
}


- (NSString *)formattedDate:(NSDate *)date
{
    if (self.rowDescriptor.valueTransformer){
        NSAssert([self.rowDescriptor.valueTransformer isSubclassOfClass:[NSValueTransformer class]], @"valueTransformer is not a subclass of NSValueTransformer");
        NSValueTransformer * valueTransformer = [self.rowDescriptor.valueTransformer new];
        NSString * tranformedValue = [valueTransformer transformedValue:self.rowDescriptor.value];
        if (tranformedValue){
            return tranformedValue;
        }
    }
    if ([self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDateInline]){
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterNoStyle;
        return [_dateFormatter stringFromDate:date];
    }
    else if ([self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeTimeInline]){
        _dateFormatter.dateStyle = NSDateFormatterNoStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        return [_dateFormatter stringFromDate:date];
    }
    else if ([self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeCountDownTimer] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeCountDownTimerInline]){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDateComponents *time = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
        return [NSString stringWithFormat:@"%ld%@ %ldmin", (long)[time hour], (long)[time hour] == 1 ? @"hour" : @"hours", (long)[time minute]];
    }
    _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    return [_dateFormatter stringFromDate:date];
}

-(void)setModeToDatePicker:(UIDatePicker *)datePicker
{
    if ((([self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDate]) && self.formDatePickerMode == DLFormDateDatePickerModeGetFromRowDescriptor) || self.formDatePickerMode == DLFormDateDatePickerModeDate){
        datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else if ((([self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeTime]) && self.formDatePickerMode == DLFormDateDatePickerModeGetFromRowDescriptor) || self.formDatePickerMode == DLFormDateDatePickerModeTime){
        datePicker.datePickerMode = UIDatePickerModeTime;
    }
    else if ([self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeCountDownTimer] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeCountDownTimerInline]){
        datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
        datePicker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    else{
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    
    if (self.minuteInterval)
        datePicker.minuteInterval = self.minuteInterval;
    
    if (self.minimumDate)
        datePicker.minimumDate = self.minimumDate;
    
    if (self.maximumDate)
        datePicker.maximumDate = self.maximumDate;
    
    if (self.locale) {
        datePicker.locale = self.locale;
    }
}

#pragma mark - Properties

-(UIDatePicker *)datePicker
{
    if (_datePicker) return _datePicker;
    _datePicker = [[UIDatePicker alloc] init];
    [self setModeToDatePicker:_datePicker];
    [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    return _datePicker;
}

-(void)setLocale:(NSLocale *)locale
{
    _locale = locale;
    _dateFormatter.locale = locale;
}

#pragma mark - Target Action

- (void)datePickerValueChanged:(UIDatePicker *)sender
{
    self.rowDescriptor.value = sender.date;
    [self.formViewController updateFormRow:self.rowDescriptor];
}

-(void)setFormDatePickerMode:(DLFormDateDatePickerMode)formDatePickerMode
{
    _formDatePickerMode = formDatePickerMode;
    if ([self isFirstResponder]){
        if ([self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeDateTimeInline] || [self.rowDescriptor.rowType isEqualToString:DLFormRowDescriptorTypeCountDownTimerInline])
        {
            NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
            NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
            DLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
            if ([nextFormRow.rowType isEqualToString:DLFormRowDescriptorTypeDatePicker]){
                DLFormDatePickerCell * datePickerCell = (DLFormDatePickerCell *)[nextFormRow cellForFormController:self.formViewController];
                [self setModeToDatePicker:datePickerCell.datePicker];
            }
        }
    }
}

@end
