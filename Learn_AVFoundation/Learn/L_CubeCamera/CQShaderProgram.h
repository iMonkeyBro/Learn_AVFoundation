//
//  CQShaderProgram.h
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/7/8.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CQShaderProgram : NSObject

- (instancetype)initWithShaderName:(NSString *)name;
- (void)addVertextAttribute:(GLKVertexAttrib)attribute named:(NSString *)name;
- (GLuint)uniformIndex:(NSString *)uniform;
- (BOOL)linkProgram;
- (void)useProgram;

@end

NS_ASSUME_NONNULL_END
