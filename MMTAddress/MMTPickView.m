//
//  MMTPickView.m
//  111
//
//  Created by LX on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "MMTPickView.h"

#define KContentHeight 250
#define KBarViewHeight 40
#define kBtnWidth 50
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MMTPickView () <UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate>
{
    UIButton           *_btnCancel;
    UIButton           *_btnConfirm;
    UIPickerView       *_pickerView;
    UIView             *_contentView;
    //
    NSDictionary       *_pickerDic;
    NSArray            *_selectedArray;
    NSArray            *_provinceArray;
    NSArray            *_cityArray;
    NSArray            *_townArray;
    NSString           *_province;
    NSString           *_city;
    NSString           *_area;
}
@property (nonatomic, copy)AddressBlock addressBlock;

@end

@implementation MMTPickView

#pragma mark -- init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        //
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT, WIDTH, KContentHeight)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        //
        _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCancel.frame = CGRectMake(0, 0, kBtnWidth, KBarViewHeight);
        [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [_btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnCancel addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_btnCancel];
        //
        _btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnConfirm.frame = CGRectMake(WIDTH - kBtnWidth, 0, kBtnWidth, KBarViewHeight);
        [_btnConfirm setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        //_btnConfirm.backgroundColor = [UIColor yellowColor];
        [_btnConfirm addTarget:self action:@selector(comfirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_btnConfirm];
        
        //
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, KBarViewHeight, WIDTH, _contentView.frame.size.height - KBarViewHeight)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        [_contentView addSubview:_pickerView];
        
        UITapGestureRecognizer *_tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)];
        _tap.delegate=self;
        //[self addGestureRecognizer:_tap];
    }
    return self;
}

+ (instancetype)showWithAddressBlock:(AddressBlock)block
{
    MMTPickView *_mianView=[[MMTPickView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _mianView.addressBlock = block;
    [_mianView  loadData];
    [_mianView show];
    return _mianView;
}

#pragma mark -- private Method

- (void)loadData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MMTAddress" ofType:@"plist"];
    _pickerDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    _provinceArray = [_pickerDic valueForKey:@"p"];
    _selectedArray = _pickerDic[@"c"][_provinceArray.firstObject];
    _cityArray = _selectedArray;
    _townArray = _pickerDic[@"a"][@"北京市-北京市"];
}

#pragma mark -- button Event

- (void)cancelBtnClick:(id)sender
{
    [self remove];
}

- (void)comfirmBtnClick:(id)sender
{
    if (!_province|| _province.length==0) {
        NSInteger selectProvince = [_pickerView selectedRowInComponent:0];
        _province = _provinceArray[selectProvince];
    }
    if (!_city || _city.length==0) {
        NSInteger selectCity     = [_pickerView selectedRowInComponent:1];
        _city = _cityArray[selectCity];
    }
    if (!_area || _area.length==0) {
        NSInteger selectArea     = [_pickerView selectedRowInComponent:2];
        _area = _townArray[selectArea];
    }
    if (self.addressBlock) {
        self.addressBlock(_province,_city,_area);
    }
    [self remove];
}

#pragma mark -- remove & show
- (void)remove
{
    CGRect contentViewFrame = _contentView.frame;
    contentViewFrame.origin.y += _contentView.frame.size.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _contentView.frame = contentViewFrame;
    } completion:^(BOOL finished) {
        [_contentView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)show
{
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    self.center = [UIApplication sharedApplication].keyWindow.center;
    CGRect contentViewFrame = CGRectMake(0, HEIGHT, WIDTH, KContentHeight);
    contentViewFrame.origin.y -= _contentView.frame.size.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _contentView.frame = contentViewFrame;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_contentView]) {
        return NO;
    }
    return YES;
}

#pragma mark -- PickerView Delegate & DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component==0) {
        return _provinceArray.count;
    }else if (component==1){
        return _cityArray.count;
    }else{
        return _townArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component==0) {
        return [_provinceArray objectAtIndex:row];
    }else if (component==1){
        return [_cityArray objectAtIndex:row];
    }else{
        return [_townArray objectAtIndex:row];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return WIDTH/3;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component==0) {
        _province=_provinceArray[row];
        _selectedArray=_pickerDic[@"c"][_province];
        if (_selectedArray.count>0) {
            _cityArray=_selectedArray;
        }else{
            _cityArray=@[];
        }
        if (_cityArray.count>0) {
            _townArray=_pickerDic[@"a"][[NSString stringWithFormat:@"%@-%@",_province,_cityArray.firstObject]];
        }else{
            _townArray=@[];
        }
        [_pickerView reloadComponent:1];
        [_pickerView selectRow:0 inComponent:1 animated:YES];
        [_pickerView reloadComponent:2];
        [_pickerView selectRow:0 inComponent:2 animated:YES];
        
    }else if (component==1){
        _townArray = _pickerDic[@"a"][[NSString stringWithFormat:@"%@-%@",_province,_cityArray[row]]];
        _city = _cityArray[row];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }else{
        _area=_townArray[row];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:14]];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

@end
