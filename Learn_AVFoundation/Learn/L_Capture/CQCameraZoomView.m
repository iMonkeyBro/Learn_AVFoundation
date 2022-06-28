//
//  CQCameraZoomView.m
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/28.
//

#import "CQCameraZoomView.h"
#import <Masonry/Masonry.h>

@interface CQCameraZoomView ()
@property (nonatomic, strong) UIButton *addBtn;  ///< 加按钮
@property (nonatomic, strong) UIButton *subtractBtn;  ///< 减按钮
@property (nonatomic, strong) UISlider *slider;  ///< 减按钮
@property (nonatomic, assign) BOOL isSliderCallback;  ///< 是否回调slider

@end

@implementation CQCameraZoomView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSliderCallback = YES;
        [self configUI];
        
    }
    return self;
}

- (void)addBtnAction {
    !self.addBtnCallbackBlock ? : self.addBtnCallbackBlock();
}

- (void)subtractBtnAction {
    !self.subtractBtnCallbackBlock ? : self.subtractBtnCallbackBlock();
}

- (void)sliderChangeAction:(UISlider *)sender {
    if (!self.isSliderCallback) return;
    !self.sliderChangeCallbackBlock ? : self.sliderChangeCallbackBlock(sender.value);
}

- (void)changeSliderValue:(CGFloat)value {
    self.isSliderCallback = NO;
    self.slider.value = value;
    self.isSliderCallback = YES;
}

- (void)configUI {
    // 调整self.layer.backgroundColor的透明度会使子视图透明度都改变
    self.layer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f].CGColor;
    [self addSubview:self.addBtn];
    [self addSubview:self.subtractBtn];
    [self addSubview:self.slider];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.mas_right).offset(-5);
        make.size.mas_equalTo(CGSizeMake(68, 68));
    }];
    [self.subtractBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.mas_left).offset(5);
        make.size.mas_equalTo(CGSizeMake(68, 68));
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.subtractBtn.mas_right).offset(5);
        make.right.equalTo(self.addBtn.mas_left).offset(-5);
        make.height.equalTo(self);
    }];
}

#pragma mark - Lazy
- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setTitle:@"+" forState:UIControlStateNormal];
        [_addBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _addBtn.titleLabel.font = [UIFont systemFontOfSize:25];
        [_addBtn addTarget:self action:@selector(addBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}

- (UIButton *)subtractBtn {
    if (!_subtractBtn) {
        _subtractBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subtractBtn setTitle:@"-" forState:UIControlStateNormal];
        [_subtractBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _subtractBtn.titleLabel.font = [UIFont systemFontOfSize:25];
        [_subtractBtn addTarget:self action:@selector(subtractBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _subtractBtn;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        [_slider addTarget:self action:@selector(sliderChangeAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

@end
