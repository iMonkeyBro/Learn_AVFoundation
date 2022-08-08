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
@property (nonatomic, strong) UIButton *modeBtn;  ///< 模式按钮
@property (nonatomic, strong) UILabel *sliderLabel;  ///< slider比例显示
@property (nonatomic, strong) UILabel *zoomLabel;  ///< 缩放显示

@end

@implementation CQCameraZoomView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configUI];
        
    }
    return self;
}

- (void)addBtnTouchDownAction {
    !self.addBtnTouchDownCallbackBlock ? : self.addBtnTouchDownCallbackBlock();
}

- (void)addBtnTouchUpAction {
    !self.addBtnTouchUpCallbackBlock ? : self.addBtnTouchUpCallbackBlock();
}

- (void)subtractBtnTouchDownAction {
    !self.subtractBtnTouchDownCallbackBlock ? : self.subtractBtnTouchDownCallbackBlock();
}
- (void)subtractBtnTouchUpAction {
    !self.subtractBtnTouchUpCallbackBlock ? : self.subtractBtnTouchUpCallbackBlock();
}

- (void)sliderChangeAction:(UISlider *)sender {
    self.sliderLabel.text = [NSString stringWithFormat:@"%.2lf", sender.value];
    !self.sliderChangeCallbackBlock ? : self.sliderChangeCallbackBlock(sender.value);
}

- (void)modeBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    !self.modeValueChangeCallbackBlock ? : self.modeValueChangeCallbackBlock(sender.selected?1:0);
}


- (void)configUI {
    // 调整self.layer.backgroundColor的透明度会使子视图透明度都改变
    self.layer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f].CGColor;
    [self addSubview:self.modeBtn];
    [self addSubview:self.addBtn];
    [self addSubview:self.subtractBtn];
    [self addSubview:self.slider];
    [self addSubview:self.zoomLabel];
    [self addSubview:self.sliderLabel];
    [self.modeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.mas_left).offset(0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.mas_right).offset(-0);
        make.size.mas_equalTo(CGSizeMake(68, 68));
    }];
    [self.subtractBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.modeBtn.mas_right).offset(0);
        make.size.mas_equalTo(CGSizeMake(68, 68));
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.subtractBtn.mas_right).offset(2);
        make.right.equalTo(self.addBtn.mas_left).offset(-2);
        make.height.equalTo(self);
    }];
    [self.sliderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.subtractBtn.mas_left);
        make.top.equalTo(self);
    }];
    [self.zoomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.addBtn.mas_right);
        make.top.equalTo(self);
    }];
    
}

#pragma mark - Lazy
- (UILabel *)sliderLabel {
    if (!_sliderLabel) {
        _sliderLabel = [[UILabel alloc] init];
        _sliderLabel.textColor = UIColor.blackColor;
        _sliderLabel.font = [UIFont systemFontOfSize:12];
    }
    return _sliderLabel;
}

- (UILabel *)zoomLabel {
    if (!_zoomLabel) {
        _zoomLabel = [[UILabel alloc] init];
        _zoomLabel.textColor = UIColor.blackColor;
        _zoomLabel.font = [UIFont systemFontOfSize:12];
    }
    return _zoomLabel;
}


- (UIButton *)modeBtn {
    if (!_modeBtn) {
        _modeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_modeBtn setTitle:@"M1" forState:UIControlStateNormal];
        [_modeBtn setTitle:@"M2" forState:UIControlStateSelected];
        [_modeBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _modeBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [_modeBtn addTarget:self action:@selector(modeBtnAction:) forControlEvents:UIControlEventTouchDown];
    }
    return _modeBtn;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setTitle:@"+" forState:UIControlStateNormal];
        [_addBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _addBtn.titleLabel.font = [UIFont systemFontOfSize:25];
        [_addBtn addTarget:self action:@selector(addBtnTouchDownAction) forControlEvents:UIControlEventTouchDown];
        [_addBtn addTarget:self action:@selector(addBtnTouchUpAction) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    }
    return _addBtn;
}

- (UIButton *)subtractBtn {
    if (!_subtractBtn) {
        _subtractBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subtractBtn setTitle:@"-" forState:UIControlStateNormal];
        [_subtractBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _subtractBtn.titleLabel.font = [UIFont systemFontOfSize:25];
        [_subtractBtn addTarget:self action:@selector(subtractBtnTouchDownAction) forControlEvents:UIControlEventTouchDown];
        [_subtractBtn addTarget:self action:@selector(subtractBtnTouchUpAction) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    }
    return _subtractBtn;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        [_slider addTarget:self action:@selector(sliderChangeAction:) forControlEvents:UIControlEventValueChanged];
        _slider.maximumTrackTintColor = UIColor.redColor;
    }
    return _slider;
}

@end
