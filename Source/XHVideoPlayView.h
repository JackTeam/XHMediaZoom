//
//  XHVideoPlayView.h
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-16.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHPlayer.h"

@interface XHVideoPlayView : UIView <XHVideoPlayerDelegate>

@property (strong, nonatomic, readonly) XHPlayer *player;
@property (nonatomic, assign) BOOL shouldShowPlayButton;

- (void)play;
- (void)pause;

@end
