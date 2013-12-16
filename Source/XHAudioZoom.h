//
//  XHAudioZoom.h
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-14.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
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
