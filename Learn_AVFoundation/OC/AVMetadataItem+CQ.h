//
//  AVMetadataItem+CQ.h
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/23.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVMetadataItem (CQ)

/// AVMetadataItem的数字key转为可读NSString
- (NSString *)keyString;

@end

NS_ASSUME_NONNULL_END
