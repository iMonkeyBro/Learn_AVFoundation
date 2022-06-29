//
//  CQCameraOperationalView.m
//  CQAVKit
//
//  Created by 刘超群 on 2021/11/27.
//

#import "CQCameraOperateView.h"
#import "CQCameraShutterButton.h"
#import <Masonry/Masonry.h>

@interface CQCameraOperateView ()
@property (nonatomic, strong) CQCameraShutterButton *shutterBtn;  ///< 快门按钮
@property (nonatomic, strong) UIButton *modeButton;  ///< 模式按键
@property (nonatomic, assign) CQCameraMode cameraMode;  ///< 相机模式
@property (nonatomic, strong) UIButton *faceButton;  ///< 人脸识别开关按键
@property (nonatomic, assign) BOOL isStartFace;  ///< 是否开启人脸识别

@property (nonatomic, strong) UIButton *codeButton;  ///< 条码识别开关按键
@property (nonatomic, assign) BOOL isStartCode;  ///< 是否开启条码识别

@end

@implementation CQCameraOperateView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configUI];
        self.cameraMode = CQCameraModePhoto;
        self.isStartFace = NO;
    }
    return self;
}

#pragma mark - Event
- (void)shutterBtnAction {
    !self.shutterBtnCallbackBlock ?: self.shutterBtnCallbackBlock();
    if (self.cameraMode == CQCameraModeVideo) {
        self.shutterBtn.selected = !self.shutterBtn.selected;
        self.modeButton.hidden = !self.modeButton.hidden;
    }
}

- (void)coverBtnAction {
    !self.coverBtnCallbackBlock ?: self.coverBtnCallbackBlock();
}

- (void)modeBtnAction {
    if (self.cameraMode == CQCameraModePhoto) {
        self.cameraMode = CQCameraModeVideo;
    } else if (self.cameraMode  == CQCameraModeVideo) {
        self.cameraMode = CQCameraModePhoto;
    }
}

- (void)faceBtnAction {
    self.isStartCode = NO;
    self.isStartFace = !self.isStartFace;
}

- (void)codeBtnAction {
    self.isStartFace = NO;
    self.isStartCode = !self.isStartCode;
}

#pragma mark - Setter
- (void)setCameraMode:(CQCameraMode)cameraMode {
    _cameraMode = cameraMode;
    if (cameraMode == CQCameraModePhoto) {
        [self.modeButton setTitle:@"Photo" forState:UIControlStateNormal];
        self.shutterBtn.mode = CQCameraShutterButtonModePhoto;
    } else if (cameraMode == CQCameraModeVideo) {
        [self.modeButton setTitle:@"Video" forState:UIControlStateNormal];
        self.shutterBtn.mode = CQCameraShutterButtonModeVideo;
    }
    !self.changeModeCallbackBlock ?: self.changeModeCallbackBlock(self.cameraMode);
}

- (void)setIsStartFace:(BOOL)isStartFace {
    if (_isStartFace != isStartFace) {
        _isStartFace = isStartFace;
        if (isStartFace == YES) {
            [self.faceButton setTitle:@"Face-ON" forState:UIControlStateNormal];
        } else {
            [self.faceButton setTitle:@"Face-OFF" forState:UIControlStateNormal];
        }
        !self.faceSwitchCallbackBlock ?: self.faceSwitchCallbackBlock(isStartFace);
    }
}

- (void)setIsStartCode:(BOOL)isStartCode {
    if (_isStartCode != isStartCode) {
        _isStartCode = isStartCode;
        if (isStartCode == YES) {
            [self.codeButton setTitle:@"Code-ON" forState:UIControlStateNormal];
        } else {
            [self.codeButton setTitle:@"Code-OFF" forState:UIControlStateNormal];
        }
        !self.codeSwitchCallbackBlock ?: self.codeSwitchCallbackBlock(isStartCode);
    }
}

#pragma mark - UI
- (void)configUI {
    // 调整self.layer.backgroundColor的透明度会使子视图透明度都改变
    self.layer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
    [self addSubview:self.shutterBtn];
    [self addSubview:self.coverBtn];
    [self addSubview:self.modeButton];
    [self addSubview:self.faceButton];
    [self addSubview:self.codeButton];
    [self.shutterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(68, 68));
    }];
    [self.coverBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(68, 68));
    }];
    [self.modeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(5);
    }];
    [self.faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self);
    }];
    [self.codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.coverBtn.mas_right).offset(2);
        make.centerY.mas_equalTo(self);
    }];
}

#pragma mark - Lazy
- (CQCameraShutterButton *)shutterBtn {
    if (!_shutterBtn) {
        _shutterBtn = [CQCameraShutterButton shutterButton];
        [_shutterBtn addTarget:self action:@selector(shutterBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shutterBtn;
}

- (UIButton *)coverBtn {
    if (!_coverBtn) {
        _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_coverBtn setImage:[UIImage imageNamed:@"icon_photo"] forState:UIControlStateNormal];
        [_coverBtn addTarget:self action:@selector(coverBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coverBtn;
}

- (UIButton *)modeButton {
    if (!_modeButton) {
        _modeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_modeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_modeButton setTitle:@"photo" forState:UIControlStateNormal];
        [_modeButton addTarget:self action:@selector(modeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _modeButton;
}

- (UIButton *)faceButton {
    if (!_faceButton) {
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_faceButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_faceButton setTitle:@"Face-OFF" forState:UIControlStateNormal];
        [_faceButton addTarget:self action:@selector(faceBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

- (UIButton *)codeButton {
    if (!_codeButton) {
        _codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_codeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_codeButton setTitle:@"Code-OFF" forState:UIControlStateNormal];
        [_codeButton addTarget:self action:@selector(codeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _codeButton;
}

@end
