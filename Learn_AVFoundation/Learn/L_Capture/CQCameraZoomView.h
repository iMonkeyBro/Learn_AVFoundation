//
//  CQCameraZoomView.h
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 缩放调节视图
@interface CQCameraZoomView : UIView

@property (nonatomic, copy) void(^addBtnCallbackBlock)(void);  ///< 加按钮回调
@property (nonatomic, copy) void(^subtractBtnCallbackBlock)(void);  ///< 减按钮回调
@property (nonatomic, copy) void(^sliderChangeCallbackBlock)(CGFloat value);  ///< slider更改回调
@property (nonatomic, strong, readonly) UISlider *slider;  ///< 减按钮

- (void)changeSliderValue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
