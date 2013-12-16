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

@interface XHVideoZoom () {
    AVPlayer      *  _player;
    AVPlayerLayer *  _playerLayer;
}

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
    if (![self isFileURL]) {
        [self.imageView addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    }
    
    _player = [AVPlayer playerWithURL:self.mediaURL];
    
    __weak typeof(self) weakSelf = self;
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 24) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weakSelf _resetActivityIndicatorView];
    }];
    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [_playerLayer setFrame:self.imageView.bounds];
    [_playerLayer setBackgroundColor:self.imageView.backgroundColor.CGColor];
    [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [self.imageView.layer setNeedsDisplayOnBoundsChange:YES];
    
    
    [self.imageView.layer addSublayer:_playerLayer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    
    [_player play];
}

- (void)itemDidFinishPlaying
{
    [self pauseVideoAndRemoveLayer];
}

- (void)pauseVideoAndRemoveLayer
{
    [_player pause];
    [_playerLayer removeFromSuperlayer];
    _player = nil;
    _playerLayer = nil;
}

- (void)willHandleSingleTap
{
    [self pauseVideoAndRemoveLayer];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [super deviceOrientationDidChange:notification];
    [_playerLayer setFrame:self.imageView.bounds];
}

@end
