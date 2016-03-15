//
//  XHAudioZoom.h
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-14.
//  Copyright (c) 2013年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "XHMediaZoom.h"

@interface XHPorgressImageView : UIImageView {
    
    UIImage * _originalImage;
    
    BOOL      _internalUpdating;
}

@property (nonatomic) float progress;
@property (nonatomic) BOOL  hasGrayscaleBackground;

@property (nonatomic, getter = isVerticalProgress) BOOL verticalProgress;

@property(nonatomic, strong) UIImage * originalImage;

- (void)commonInit;
- (void)updateDrawing;
@end

@interface XHAudioHud : UIView
@property (nonatomic, assign) float progress;

- (void)setProgress:(float)progress;
- (void)setProgress:(float)progress animated:(BOOL)animated;

@end


@interface XHAudioZoom : XHMediaZoom

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
                   audioUrl:(NSURL *)audioUrl;

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
                   audioUrl:(NSURL *)audioUrl
                 blurEffect:(BOOL)useBlur;
@end
