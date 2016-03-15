//
//  XHPlayer.m
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-16.
//  Copyright (c) 2013年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "XHPlayer.h"

static NSString * const XHVideoPlayerControllerTracksKey = @"tracks";
static NSString * const XHVideoPlayerControllerPlayableKey = @"playable";
static NSString * const XHVideoPlayerControllerDurationKey = @"duration";

@interface XHPlayer () {
	BOOL _loading;
}

@property (strong, nonatomic, readwrite) AVPlayerItem * oldItem;
@property (assign, nonatomic, readwrite, getter=isLoading) BOOL loading;
@property (assign, nonatomic) Float64 itemsLoopLength;
@property (strong, nonatomic, readwrite) id timeObserver;

@end

@implementation XHPlayer

XHPlayer * currentSCVideoPlayer = nil;

@synthesize oldItem;

- (id)init {
	self = [super init];
	
	if (self) {
		self.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
		[self addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:nil];
		
		__unsafe_unretained XHPlayer * mySelf = self;
		self.timeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMake(1, 24) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
			if ([mySelf.delegate respondsToSelector:@selector(videoPlayer:didPlay:timeTotal:)]) {
				Float64 ratio = 1.0 / mySelf.itemsLoopLength;
				[mySelf.delegate videoPlayer:mySelf didPlay:CMTimeMultiplyByFloat64(time, ratio) timeTotal: CMTimeMultiplyByFloat64(mySelf.currentItem.duration, ratio)];
			}
		}];
		_loading = NO;
		
		self.minimumBufferedTimeBeforePlaying = CMTimeMake(2, 1);
	}
	
	return self;
}

- (void)dealloc {
    [self dispose];
}

- (void)dispose {
    self.delegate = nil;
	[self removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
	[self setItem:nil];
	self.oldItem = nil;
}

- (void)playReachedEnd:(NSNotification*)notification {
	if (notification.object == self.currentItem) {
		if (self.shouldLoop) {
			[self seekToTime:CMTimeMake(0, 1)];
			if ([self isPlaying]) {
				[self play];
			}
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"currentItem"]) {
		[self initObserver];
	} else {
		if (object == self.currentItem) {
			if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
				if (!self.isLoading) {
					self.loading = YES;
				}
			} else {
				CMTime playableDuration = [self playableDuration];
				CMTime minimumTime = self.minimumBufferedTimeBeforePlaying;
				CMTime itemTime = self.currentItem.duration;
				
				if (CMTIME_COMPARE_INLINE(minimumTime, >, itemTime)) {
					minimumTime = itemTime;
				}
				
				if (CMTIME_COMPARE_INLINE(playableDuration, >=, minimumTime)) {
					if ([self isPlaying]) {
						[self play];
					}
					if (self.isLoading) {
						self.loading = NO;
					}
				}
			}
		}
	}
}

- (void)initObserver {
	if (self.oldItem != nil) {
		[self.oldItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
		[self.oldItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
		[self.oldItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.oldItem];
	}
	
	if (self.currentItem != nil) {
		[self.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
		[self.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
		[self.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:
		 NSKeyValueObservingOptionNew context:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
	}
	
	self.loading = NO;
    
	self.oldItem = self.currentItem;
	
	if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeItem:)]) {
		[self.delegate videoPlayer:self didChangeItem:self.currentItem];
	}
}

- (void)play {
	if (currentSCVideoPlayer != self) {
		[XHPlayer pauseCurrentPlayer];
	}
	
	[super play];
	
	currentSCVideoPlayer = self;
}

- (void)pause {
	[super pause];
	
	if (currentSCVideoPlayer == self) {
		currentSCVideoPlayer = nil;
	}
}

- (CMTime)playableDuration {
	AVPlayerItem * item = self.currentItem;
	CMTime playableDuration = kCMTimeZero;
	
	if (item.status == AVPlayerItemStatusReadyToPlay) {
		
		if (item.loadedTimeRanges.count > 0) {
			NSValue * value = [item.loadedTimeRanges objectAtIndex:0];
			CMTimeRange timeRange = [value CMTimeRangeValue];
			
			playableDuration = timeRange.duration;
		}
	}
	
	return playableDuration;
}

- (void)setItemByStringPath:(NSString *)stringPath {
    if (!stringPath)
        return;
	[self setItemByUrl:[NSURL fileURLWithPath:stringPath]];
}

- (void)setItemByUrl:(NSURL *)url {
	[self setItemByAsset:[AVURLAsset URLAssetWithURL:url options:nil]];
}

- (void)setItemByAsset:(AVAsset *)asset {
	[self setItem:[AVPlayerItem playerItemWithAsset:asset]];
}

- (void)setItem:(AVPlayerItem *)item {
	self.itemsLoopLength = 1;
	[self replaceCurrentItemWithPlayerItem:item];
}

- (void)setSmoothLoopItemByStringPath:(NSString *)stringPath smoothLoopCount:(NSUInteger)loopCount {
	[self setSmoothLoopItemByUrl:[NSURL fileURLWithPath:stringPath] smoothLoopCount:loopCount];
}

- (void)setSmoothLoopItemByUrl:(NSURL *)url smoothLoopCount:(NSUInteger)loopCount {
	[self setSmoothLoopItemByAsset:[AVURLAsset URLAssetWithURL:url options:nil] smoothLoopCount:loopCount];
}

- (void)setSmoothLoopItemByAsset:(AVAsset *)asset smoothLoopCount:(NSUInteger)loopCount {

	/* 旧的方法不能播放远程视频
	AVMutableComposition * composition = [AVMutableComposition composition];
	
	CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
	
	for (NSUInteger i = 0; i < loopCount; i++) {
		[composition insertTimeRange:timeRange ofAsset:asset atTime:composition.duration error:nil];
	}
	
	[self setItemByAsset:composition];
     
     */
    
    NSArray *keys = @[XHVideoPlayerControllerTracksKey, XHVideoPlayerControllerPlayableKey, XHVideoPlayerControllerDurationKey];
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // setup player
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
            [self setItem:playerItem];
        });
    }];
	
	self.itemsLoopLength = loopCount;
}

- (BOOL)isPlaying {
	return currentSCVideoPlayer == self;
}

- (void)setLoading:(BOOL)loading {
	_loading = loading;
	
	if (loading) {
		if ([self.delegate respondsToSelector:@selector(videoPlayer:didStartLoadingAtItemTime:)]) {
			[self.delegate videoPlayer:self didStartLoadingAtItemTime:self.currentItem.currentTime];
		}
	} else {
		if ([self.delegate respondsToSelector:@selector(videoPlayer:didEndLoadingAtItemTime:)]) {
			[self.delegate videoPlayer:self didEndLoadingAtItemTime:self.currentItem.currentTime];
		}
	}
}

+ (XHPlayer *)videoPlayer {
	return [[XHPlayer alloc] init];
}

+ (void)pauseCurrentPlayer {
	if (currentSCVideoPlayer != nil) {
		[currentSCVideoPlayer pause];
	}
}

+ (XHPlayer *)currentPlayer {
	return currentSCVideoPlayer;
}

@end
