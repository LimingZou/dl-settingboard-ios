//
//  DLFormDescriptor.m
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


#import "NSObject+DLFormAdditions.h"
#import "DLFormDescriptor.h"
#import "NSPredicate+DLFormAdditions.h"
#import "NSString+DLFormAdditions.h"

NSString * const DLFormErrorDomain = @"DLFormErrorDomain";
NSString * const DLValidationStatusErrorKey = @"DLValidationStatusErrorKey";


@interface DLFormSectionDescriptor (_DLFormDescriptor)

@property NSArray * allRows;
-(BOOL)evaluateIsHidden;

@end


@interface DLFormRowDescriptor(_DLFormDescriptor)

-(BOOL)evaluateIsDisabled;
-(BOOL)evaluateIsHidden;

@end


@interface DLFormDescriptor()

@property NSMutableArray * formSections;
@property (readonly) NSMutableArray * allSections;
@property NSString * title;
@property (readonly) NSMutableDictionary* allRowsByTag;
@property NSMutableDictionary* rowObservers;

@end

@implementation DLFormDescriptor

-(instancetype)init
{
    return [self initWithTitle:nil];
}

-(instancetype)initWithTitle:(NSString *)title;
{
    self = [super init];
    if (self){
        _formSections = [NSMutableArray array];
        _allSections = [NSMutableArray array];
        _allRowsByTag = [NSMutableDictionary dictionary];
        _rowObservers = [NSMutableDictionary dictionary];
        _title = title;
        _addAsteriskToRequiredRowsTitle = NO;
        _disabled = NO;
        _endEditingTableViewOnScroll = YES;
        _rowNavigationOptions = DLFormRowNavigationOptionEnabled;
        [self addObserver:self forKeyPath:@"formSections" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:0];
    }
    return self;
}

+(instancetype)formDescriptor
{
    return [[self class] formDescriptorWithTitle:nil];
}

+(instancetype)formDescriptorWithTitle:(NSString *)title
{
    return [[[self class] alloc] initWithTitle:title];
}

-(void)addFormSection:(DLFormSectionDescriptor *)formSection
{
    [self insertObject:formSection inAllSectionsAtIndex:[self.allSections count]];
}

-(void)addFormSection:(DLFormSectionDescriptor *)formSection atIndex:(NSUInteger)index
{
    if (index == 0){
        [self insertObject:formSection inAllSectionsAtIndex:0];
    }
    else{
        DLFormSectionDescriptor* previousSection = [self.formSections objectAtIndex:MIN(self.formSections.count, index-1)];
        [self addFormSection:formSection afterSection:previousSection];
    }
}

-(void)addFormSection:(DLFormSectionDescriptor *)formSection afterSection:(DLFormSectionDescriptor *)afterSection
{
    NSUInteger sectionIndex;
    NSUInteger allSectionIndex;
    if ((sectionIndex = [self.allSections indexOfObject:formSection]) == NSNotFound){
        allSectionIndex = [self.allSections indexOfObject:afterSection];
        if (allSectionIndex != NSNotFound) {
            [self insertObject:formSection inAllSectionsAtIndex:(allSectionIndex + 1)];
        }
        else { //case when afterSection does not exist. Just insert at the end.
            [self addFormSection:formSection];
            return;
        }
    }
    formSection.hidden = formSection.hidden;
}


-(void)addFormRow:(DLFormRowDescriptor *)formRow beforeRow:(DLFormRowDescriptor *)beforeRow
{
    if (beforeRow.sectionDescriptor){
        [beforeRow.sectionDescriptor addFormRow:formRow beforeRow:beforeRow];
    }
    else{
        [[self.allSections lastObject] addFormRow:formRow beforeRow:beforeRow];
    }
}

-(void)addFormRow:(DLFormRowDescriptor *)formRow beforeRowTag:(NSString *)beforeRowTag
{
    DLFormRowDescriptor * beforeRowForm = [self formRowWithTag:beforeRowTag];
    [self addFormRow:formRow beforeRow:beforeRowForm];
}



-(void)addFormRow:(DLFormRowDescriptor *)formRow afterRow:(DLFormRowDescriptor *)afterRow
{
    if (afterRow.sectionDescriptor){
        [afterRow.sectionDescriptor addFormRow:formRow afterRow:afterRow];
    }
    else{
        [[self.allSections lastObject] addFormRow:formRow afterRow:afterRow];
    }
}

-(void)addFormRow:(DLFormRowDescriptor *)formRow afterRowTag:(NSString *)afterRowTag
{
    DLFormRowDescriptor * afterRowForm = [self formRowWithTag:afterRowTag];
    [self addFormRow:formRow afterRow:afterRowForm];
}

-(void)removeFormSectionAtIndex:(NSUInteger)index
{
    if (self.formSections.count > index){
        DLFormSectionDescriptor *formSection = [self.formSections objectAtIndex:index];
        [self removeObjectFromFormSectionsAtIndex:index];
        NSUInteger allSectionIndex = [self.allSections indexOfObject:formSection];
        [self removeObjectFromAllSectionsAtIndex:allSectionIndex];
    }
}

-(void)removeFormSection:(DLFormSectionDescriptor *)formSection
{
    NSUInteger index = NSNotFound;
    if ((index = [self.formSections indexOfObject:formSection]) != NSNotFound){
        [self removeFormSectionAtIndex:index];
    }
    else if ((index = [self.allSections indexOfObject:formSection]) != NSNotFound){
        [self removeObjectFromAllSectionsAtIndex:index];
    };
}

-(void)removeFormRow:(DLFormRowDescriptor *)formRow
{
    for (DLFormSectionDescriptor * section in self.formSections){
        if ([section.formRows containsObject:formRow]){
            [section removeFormRow:formRow];
        }
    }
}

-(void)showFormSection:(DLFormSectionDescriptor*)formSection
{
    NSUInteger formIndex = [self.formSections indexOfObject:formSection];
    if (formIndex != NSNotFound) {
        return;
    }
    NSUInteger index = [self.allSections indexOfObject:formSection];
    if (index != NSNotFound){
        while (formIndex == NSNotFound && index > 0) {
            DLFormSectionDescriptor* previous = [self.allSections objectAtIndex:--index];
            formIndex = [self.formSections indexOfObject:previous];
        }
        [self insertObject:formSection inFormSectionsAtIndex:(formIndex == NSNotFound ? 0 : ++formIndex)];
    }
}

-(void)hideFormSection:(DLFormSectionDescriptor*)formSection
{
    NSUInteger index = [self.formSections indexOfObject:formSection];
    if (index != NSNotFound){
        [self removeObjectFromFormSectionsAtIndex:index];
    }
}


-(DLFormRowDescriptor *)formRowWithTag:(NSString *)tag
{
    return self.allRowsByTag[tag];
}

-(DLFormRowDescriptor *)formRowWithHash:(NSUInteger)hash
{
    for (DLFormSectionDescriptor * section in self.allSections){
        for (DLFormRowDescriptor * row in section.allRows) {
            if ([row hash] == hash){
                return row;
            }
        }
    }
    return nil;
}


-(void)removeFormRowWithTag:(NSString *)tag
{
    DLFormRowDescriptor * formRow = [self formRowWithTag:tag];
    [self removeFormRow:formRow];
}

-(DLFormRowDescriptor *)formRowAtIndex:(NSIndexPath *)indexPath
{
    if ((self.formSections.count > indexPath.section) && [[self.formSections objectAtIndex:indexPath.section] formRows].count > indexPath.row){
        return [[[self.formSections objectAtIndex:indexPath.section] formRows] objectAtIndex:indexPath.row];
    }
    return nil;
}

-(DLFormSectionDescriptor *)formSectionAtIndex:(NSUInteger)index
{
    return [self objectInFormSectionsAtIndex:index];
}

-(NSIndexPath *)indexPathOfFormRow:(DLFormRowDescriptor *)formRow
{
    DLFormSectionDescriptor * section = formRow.sectionDescriptor;
    if (section){
        NSUInteger sectionIndex = [self.formSections indexOfObject:section];
        if (sectionIndex != NSNotFound){
            NSUInteger rowIndex = [section.formRows indexOfObject:formRow];
            if (rowIndex != NSNotFound){
                return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            }
        }
    }
    return nil;
}

-(NSIndexPath *)globalIndexPathOfFormRow:(DLFormRowDescriptor *)formRow
{
    DLFormSectionDescriptor * section = formRow.sectionDescriptor;
    if (section){
        NSUInteger sectionIndex = [self.allSections indexOfObject:section];
        if (sectionIndex != NSNotFound){
            NSUInteger rowIndex = [section.allRows indexOfObject:formRow];
            if (rowIndex != NSNotFound){
                return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            }
        }
    }
    return nil;
}

-(NSDictionary *)formValues
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    for (DLFormSectionDescriptor * section in self.formSections) {
        if (section.multivaluedTag.length > 0){
            NSMutableArray * multiValuedValuesArray = [NSMutableArray new];
            for (DLFormRowDescriptor * row in section.formRows) {
                if (row.value){
                    [multiValuedValuesArray addObject:row.value];
                }
            }
            [result setObject:multiValuedValuesArray forKey:section.multivaluedTag];
        }
        else{
            for (DLFormRowDescriptor * row in section.formRows) {
                if (row.tag.length > 0){
                    [result setObject:(row.value ?: [NSNull null]) forKey:row.tag];
                }
            }
        }
    }
    return result;
}

-(NSDictionary *)httpParameters:(DLFormViewController *)formViewController
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    for (DLFormSectionDescriptor * section in self.formSections) {
        if (section.multivaluedTag.length > 0){
            NSMutableArray * multiValuedValuesArray = [NSMutableArray new];
            for (DLFormRowDescriptor * row in section.formRows) {
                if ([row.value valueData]){
                    [multiValuedValuesArray addObject:[row.value valueData]];
                }
            }
            [result setObject:multiValuedValuesArray forKey:section.multivaluedTag];
        }
        else{
            for (DLFormRowDescriptor * row in section.formRows) {
                NSString * httpParameterKey = nil;
                if ((httpParameterKey = [self httpParameterKeyForRow:row cell:[row cellForFormController:formViewController]])){
                    id parameterValue = [row.value valueData] ?: [NSNull null];
                    [result setObject:parameterValue forKey:httpParameterKey];
                }
            }
        }
    }
    return result;
}

-(NSString *)httpParameterKeyForRow:(DLFormRowDescriptor *)row cell:(UITableViewCell<DLFormDescriptorCell> *)descriptorCell
{
    if ([descriptorCell respondsToSelector:@selector(formDescriptorHttpParameterName)]){
        return [descriptorCell formDescriptorHttpParameterName];
    }
    if (row.tag.length > 0){
        return row.tag;
    }
    return nil;
}

-(NSArray *)localValidationErrors:(DLFormViewController *)formViewController {
    NSMutableArray * result = [NSMutableArray array];
    for (DLFormSectionDescriptor * section in self.formSections) {
        for (DLFormRowDescriptor * row in section.formRows) {
            DLFormValidationStatus* status = [row doValidation];
            if (status != nil && (![status isValid])) {
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: status.msg,
                                            DLValidationStatusErrorKey: status };
                NSError * error = [[NSError alloc] initWithDomain:DLFormErrorDomain code:DLFormErrorCodeGen userInfo:userInfo];
                if (error){
                    [result addObject:error];
                }
            }
        }
    }
    
    return result;
}


- (void)setFirstResponder:(DLFormViewController *)formViewController
{
    for (DLFormSectionDescriptor * formSection in self.formSections) {
        for (DLFormRowDescriptor * row in formSection.formRows) {
            UITableViewCell<DLFormDescriptorCell> * cell = [row cellForFormController:formViewController];
            if ([cell formDescriptorCellCanBecomeFirstResponder]){
                if ([cell formDescriptorCellBecomeFirstResponder]){
                    return;
                }
            }
        }
    }
}


#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!self.delegate) return;
    if ([keyPath isEqualToString:@"formSections"]){
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]){
            NSIndexSet * indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            DLFormSectionDescriptor * section = [self.formSections objectAtIndex:indexSet.firstIndex];
            [self.delegate formSectionHasBeenAdded:section atIndex:indexSet.firstIndex];
        }
        else if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeRemoval)]){
            NSIndexSet * indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            DLFormSectionDescriptor * removedSection = [[change objectForKey:NSKeyValueChangeOldKey] objectAtIndex:0];
            [self.delegate formSectionHasBeenRemoved:removedSection atIndex:indexSet.firstIndex];
        }
    }
}

-(void)dealloc
{
    @try {
        [self removeObserver:self forKeyPath:@"formSections"];
    }
    @catch (NSException * __unused exception) {}
}

#pragma mark - KVC

-(NSUInteger)countOfFormSections
{
    return self.formSections.count;
}

- (id)objectInFormSectionsAtIndex:(NSUInteger)index {
    return [self.formSections objectAtIndex:index];
}

- (NSArray *)formSectionsAtIndexes:(NSIndexSet *)indexes {
    return [self.formSections objectsAtIndexes:indexes];
}

- (void)insertObject:(DLFormSectionDescriptor *)formSection inFormSectionsAtIndex:(NSUInteger)index {
    [self.formSections insertObject:formSection atIndex:index];
}

- (void)removeObjectFromFormSectionsAtIndex:(NSUInteger)index {
    [self.formSections removeObjectAtIndex:index];
}

#pragma mark - allSections KVO

-(NSUInteger)countOfAllSections
{
    return self.allSections.count;
}

- (id)objectInAllSectionsAtIndex:(NSUInteger)index {
    return [self.allSections objectAtIndex:index];
}

- (NSArray *)allSectionsAtIndexes:(NSIndexSet *)indexes {
    return [self.allSections objectsAtIndexes:indexes];
}

- (void)removeObjectFromAllSectionsAtIndex:(NSUInteger)index {
    DLFormSectionDescriptor* section = [self.allSections objectAtIndex:index];
    [section.allRows enumerateObjectsUsingBlock:^(id obj, NSUInteger __unused idx, BOOL *stop) {
        DLFormRowDescriptor * row = (id)obj;
        [self removeObserversOfObject:row predicateType:XLPredicateTypeDisabled];
        [self removeObserversOfObject:row predicateType:XLPredicateTypeHidden];
    }];
    [self removeObserversOfObject:section predicateType:XLPredicateTypeHidden];
    [self.allSections removeObjectAtIndex:index];
}

- (void)insertObject:(DLFormSectionDescriptor *)section inAllSectionsAtIndex:(NSUInteger)index {
    section.formDescriptor = self;
    [self.allSections insertObject:section atIndex:index];
    section.hidden = section.hidden;
    [section.allRows enumerateObjectsUsingBlock:^(id obj, NSUInteger __unused idx, BOOL * __unused stop) {
        DLFormRowDescriptor * row = (id)obj;
        [self addRowToTagCollection:obj];
        row.hidden = row.hidden;
        row.disabled = row.disabled;
    }];

    
}

#pragma mark - EvaluateForm

-(void)forceEvaluate
{
    for (DLFormSectionDescriptor* section in self.allSections){
        for (DLFormRowDescriptor* row in section.allRows) {
            [self addRowToTagCollection:row];
        }
    }
    for (DLFormSectionDescriptor* section in self.allSections){
        for (DLFormRowDescriptor* row in section.allRows) {
            [row evaluateIsDisabled];
            [row evaluateIsHidden];
        }
        [section evaluateIsHidden];
    }
}

#pragma mark - private


-(NSMutableArray *)formSections
{
    return _formSections;
}

#pragma mark - Helpers

-(DLFormRowDescriptor *)nextRowDescriptorForRow:(DLFormRowDescriptor *)row
{
    NSUInteger indexOfRow = [row.sectionDescriptor.formRows indexOfObject:row];
    if (indexOfRow != NSNotFound){
        if (indexOfRow + 1 < row.sectionDescriptor.formRows.count){
            return [row.sectionDescriptor.formRows objectAtIndex:++indexOfRow];
        }
        else{
            NSUInteger sectionIndex = [self.formSections indexOfObject:row.sectionDescriptor];
            NSUInteger numberOfSections = [self.formSections count];
            if (sectionIndex != NSNotFound && sectionIndex < numberOfSections - 1){
                sectionIndex++;
                DLFormSectionDescriptor * sectionDescriptor;
                while ([[(sectionDescriptor = [row.sectionDescriptor.formDescriptor.formSections objectAtIndex:sectionIndex]) formRows] count] == 0 && sectionIndex < numberOfSections - 1){
                    sectionIndex++;
                }
                return [sectionDescriptor.formRows firstObject];
            }
        }
    }
    return nil;
}


-(DLFormRowDescriptor *)previousRowDescriptorForRow:(DLFormRowDescriptor *)row
{
    NSUInteger indexOfRow = [row.sectionDescriptor.formRows indexOfObject:row];
    if (indexOfRow != NSNotFound){
        if (indexOfRow > 0 ){
            return [row.sectionDescriptor.formRows objectAtIndex:--indexOfRow];
        }
        else{
            NSUInteger sectionIndex = [self.formSections indexOfObject:row.sectionDescriptor];
            if (sectionIndex != NSNotFound && sectionIndex > 0){
                sectionIndex--;
                DLFormSectionDescriptor * sectionDescriptor;
                while ([[(sectionDescriptor = [row.sectionDescriptor.formDescriptor.formSections objectAtIndex:sectionIndex]) formRows] count] == 0 && sectionIndex > 0 ){
                    sectionIndex--;
                }
                return [sectionDescriptor.formRows lastObject];
            }
        }
    }
    return nil;
}

-(void)addRowToTagCollection:(DLFormRowDescriptor*) rowDescriptor
{
    if (rowDescriptor.tag) {
        self.allRowsByTag[rowDescriptor.tag] = rowDescriptor;
    }
}

-(void)removeRowFromTagCollection:(DLFormRowDescriptor *)rowDescriptor
{
    if (rowDescriptor.tag){
        [self.allRowsByTag removeObjectForKey:rowDescriptor.tag];
    }
}


-(void)addObserversOfObject:(id)sectionOrRow predicateType:(XLPredicateType)predicateType
{
    NSPredicate* predicate;
    id descriptor;
    switch(predicateType){
        case XLPredicateTypeHidden:
            if ([sectionOrRow isKindOfClass:([DLFormRowDescriptor class])]) {
                descriptor = ((DLFormRowDescriptor*)sectionOrRow).tag;
                predicate = ((DLFormRowDescriptor*)sectionOrRow).hidden;
            }
            else if ([sectionOrRow isKindOfClass:([DLFormSectionDescriptor class])]) {
                descriptor = sectionOrRow;
                predicate = ((DLFormSectionDescriptor*)sectionOrRow).hidden;
            }
            break;
        case XLPredicateTypeDisabled:
            if ([sectionOrRow isKindOfClass:([DLFormRowDescriptor class])]) {
                descriptor = ((DLFormRowDescriptor*)sectionOrRow).tag;
                predicate = ((DLFormRowDescriptor*)sectionOrRow).disabled;
            }
            else return;
            
            break;
    }
    NSMutableArray* tags = [predicate getPredicateVars];
    for (NSString* tag in tags) {
        NSString* auxTag = [tag formKeyForPredicateType:predicateType];
        if (!self.rowObservers[auxTag]){
            self.rowObservers[auxTag] = [NSMutableArray array];
        }
        if (![self.rowObservers[auxTag] containsObject:descriptor])
            [self.rowObservers[auxTag] addObject:descriptor];
    }
    
}

-(void)removeObserversOfObject:(id)sectionOrRow predicateType:(XLPredicateType)predicateType
{
    NSPredicate* predicate;
    id descriptor;
    switch(predicateType){
        case XLPredicateTypeHidden:
            if ([sectionOrRow isKindOfClass:([DLFormRowDescriptor class])]) {
                descriptor = ((DLFormRowDescriptor*)sectionOrRow).tag;
                predicate = ((DLFormRowDescriptor*)sectionOrRow).hidden;
            }
            else if ([sectionOrRow isKindOfClass:([DLFormSectionDescriptor class])]) {
                descriptor = sectionOrRow;
                predicate = ((DLFormSectionDescriptor*)sectionOrRow).hidden;
            }
            break;
        case XLPredicateTypeDisabled:
            if ([sectionOrRow isKindOfClass:([DLFormRowDescriptor class])]) {
                descriptor = ((DLFormRowDescriptor*)sectionOrRow).tag;
                predicate = ((DLFormRowDescriptor*)sectionOrRow).disabled;
            }
            break;
    }
    if (descriptor && [predicate isKindOfClass:[NSPredicate class] ]) {
        NSMutableArray* tags = [predicate getPredicateVars];
        for (NSString* tag in tags) {
            NSString* auxTag = [tag formKeyForPredicateType:predicateType];
            if (self.rowObservers[auxTag]){
                [self.rowObservers[auxTag] removeObject:descriptor];
            }
        }
    }
}

@end
