//
//  XHPlayer.h
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-16.
//  Copyright (c) 2013年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class XHPlayer;

@protocol XHVideoPlayerDelegate <NSObject>

@optional

- (void) videoPlayer:(XHPlayer*)videoPlayer didPlay:(CMTime)secondsElapsed timeTotal:(CMTime)timeTotal;
- (void) videoPlayer:(XHPlayer *)videoPlayer didStartLoadingAtItemTime:(CMTime)itemTime;
- (void) videoPlayer:(XHPlayer *)videoPlayer didEndLoadingAtItemTime:(CMTime)itemTime;
- (void) videoPlayer:(XHPlayer *)videoPlayer didChangeItem:(AVPlayerItem*)item;

@end

@interface XHPlayer : AVPlayer

+ (XHPlayer *) videoPlayer;
+ (void)pauseCurrentPlayer;
+ (XHPlayer *) currentPlayer;

- (void)dispose;

- (void)setItemByStringPath:(NSString*)stringPath;
- (void)setItemByUrl:(NSURL*)url;
- (void)setItemByAsset:(AVAsset*)asset;
- (void)setItem:(AVPlayerItem*)item;


//这些方法允许玩家添加相同的项“loopCount”时间
//为了顺利循环。苹果提供的循环系统
//有一个unvoidable打嗝。使用这些方法将为“loopCount”时间避免打嗝

- (void)setSmoothLoopItemByStringPath:(NSString*)stringPath smoothLoopCount:(NSUInteger)loopCount;
- (void)setSmoothLoopItemByUrl:(NSURL*)url smoothLoopCount:(NSUInteger)loopCount;
- (void)setSmoothLoopItemByAsset:(AVAsset*)asset smoothLoopCount:(NSUInteger)loopCount;

- (CMTime)playableDuration;
- (BOOL)isPlaying;
- (BOOL)isLoading;

@property (weak, nonatomic, readwrite) id <XHVideoPlayerDelegate> delegate;
@property (assign, nonatomic, readwrite) CMTime minimumBufferedTimeBeforePlaying;
@property (assign, nonatomic, readwrite) BOOL shouldLoop;
@end
