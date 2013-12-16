//
//  XHVideoZoom.h
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-14.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import "XHMediaZoom.h"

@interface XHVideoZoom : XHMediaZoom

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
                   videoUrl:(NSURL *)videoUrl;

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
                   videoUrl:(NSURL *)videoUrl
                 blurEffect:(BOOL)useBlur;

@end
