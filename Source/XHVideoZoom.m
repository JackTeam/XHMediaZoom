//
//  XHVideoZoom.m
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-14.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import "XHVideoZoom.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "XHVideoPlayView.h"

@interface XHVideoZoom () {
}

@property (nonatomic, strong) XHVideoPlayView *playView;

@end

@implementation XHVideoZoom

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
                   videoUrl:(NSURL *)videoUrl
{
    return [self initWithAnimationTime:duration imageView:imageView videoUrl:videoUrl blurEffect:NO];
}

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
                   videoUrl:(NSURL *)videoUrl
                 blurEffect:(BOOL)useBlur
{
    self = [super initWithAnimationTime:duration imageView:imageView blurEffect:useBlur];
    if (self)
    {
        self.mediaURL = videoUrl;
    }
    return self;
}

- (void)dealloc {
    [self pauseVideoAndRemoveLayer];
}

- (void)showAnimationDidFinish
{
    if (self.didShowHandler)
        self.didShowHandler();
    
    _playView = [[XHVideoPlayView alloc] initWithFrame:self.imageView.bounds];
    
    if ([self isFileURL]) {
        [_playView.player setSmoothLoopItemByStringPath:self.mediaURL.path smoothLoopCount:2];
    } else {
        [self.imageView addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
        [_playView.player setSmoothLoopItemByUrl:self.mediaURL smoothLoopCount:2];
    }
    
    _playView.player.shouldLoop = YES;
    _playView.shouldShowPlayButton = NO;
    [self.imageView addSubview:self.playView];
    
    [self.playView play];
}

- (void)pauseVideoAndRemoveLayer
{
    [self.playView pause];
    [self.playView removeFromSuperview];
}

- (void)willHandleSingleTap
{
    [self pauseVideoAndRemoveLayer];
    [self _resetActivityIndicatorView];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [super deviceOrientationDidChange:notification];
    [self.playView setFrame:self.imageView.bounds];
}

@end
