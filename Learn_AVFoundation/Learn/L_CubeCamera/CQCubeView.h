//
//  CQCubeView.h
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/7/8.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CMSampleBuffer.h>
#import <GLKit/GLKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CQCubeView : GLKViewController

@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;  ///< 需要渲染的buffer

@property (nonatomic, assign) CMSampleBufferRef sampleBuffer; 

@end

NS_ASSUME_NONNULL_END
