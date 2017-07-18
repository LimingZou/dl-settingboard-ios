//
//  DLFormSliderCell.m
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

#import "DLFormSliderCell.h"
#import "UIView+DLFormAdditions.h"

@interface DLFormSliderCell ()

@property (nonatomic) UISlider * slider;
@property (nonatomic) UILabel * textLabel;
@property (nonatomic) UILabel * currentStepValue;

@property NSUInteger steps;

@end

@implementation DLFormSliderCell

@synthesize textLabel = _textLabel;

- (void)configure
{
	self.steps = 0;
	[self.slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.contentView addSubview:self.slider];
	[self.contentView addSubview:self.textLabel];
    [self.contentView addSubview:self.currentStepValue];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.slider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:44]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textLabel]-|" options:0 metrics:0 views:@{@"textLabel": self.textLabel}]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[slider]-|" options:0 metrics:0 views:@{@"slider": self.slider}]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.currentStepValue attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[stepValue]-|" options:0 metrics:0 views:@{@"stepValue": self.currentStepValue}]];
	
	[self valueChanged:nil];
}

-(void)update {
	
    [super update];
    self.textLabel.text = self.rowDescriptor.title;
    self.slider.value = [self.rowDescriptor.value floatValue];
    self.slider.enabled = !self.rowDescriptor.isDisabled;
    [self valueChanged:nil];
}

-(void)valueChanged:(UISlider*)_slider {
	if(self.steps != 0) {
		self.slider.value = roundf((self.slider.value-self.slider.minimumValue)/(self.slider.maximumValue-self.slider.minimumValue)*self.steps)*(self.slider.maximumValue-self.slider.minimumValue)/self.steps + self.slider.minimumValue;
	}
    self.currentStepValue.text = [NSString stringWithFormat:@"%.1f", self.slider.value];
	self.rowDescriptor.value = @(self.slider.value);
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(DLFormRowDescriptor *)rowDescriptor {
	return 88;
}


-(UILabel *)textLabel
{
    if (_textLabel) return _textLabel;
    _textLabel = [UILabel autolayoutView];
    return _textLabel;
}

-(UISlider *)slider
{
    if (_slider) return _slider;
    _slider = [UISlider autolayoutView];
    return _slider;
}
-(UILabel *)currentStepValue
{
    if (!_currentStepValue) {
        _currentStepValue = [UILabel autolayoutView];
        _currentStepValue.textAlignment = NSTextAlignmentRight;
        _currentStepValue.textColor = self.detailTextLabel.textColor;
    }
    return _currentStepValue;
}
@end
