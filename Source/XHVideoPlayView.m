//
//  XHVideoPlayView.m
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-16.
//  Copyright (c) 2013年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "XHVideoPlayView.h"

@interface XHVideoPlayView ()

@property (strong, nonatomic, readwrite) XHPlayer *player;
@property (strong, nonatomic, readwrite) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIButton *playButton;

@end

@implementation XHVideoPlayView

#pragma mark - Propertys

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        [_playButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
        _playButton.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        _playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_playButton addTarget:self action:@selector(playPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (void)setShouldShowPlayButton:(BOOL)shouldShowPlayButton {
    _shouldShowPlayButton = shouldShowPlayButton;
    if (_shouldShowPlayButton) {
        [self addSubview:self.playButton];
    } else {
        if (_playButton)
            [_playButton removeFromSuperview];
    }
}

#pragma mark - Handle

- (void)play {
    _playButton.hidden = YES;
    [self.player play];
}

- (void)playPressed:(UIButton *)sender {
    // 播放
    [self play];
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    [self pause];
}

- (void)pause {
    if (_playButton)
        _playButton.hidden = NO;
    [self.player pause];
}

#pragma mark - Left cycle init

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self commonInit];
    }
    return self;
}

- (void)dealloc {
	[self.player dispose];
	self.playerLayer.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (void)commonInit {
	self.player = [XHPlayer videoPlayer];
	self.player.delegate = self;
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.layer addSublayer:self.playerLayer];
	
	self.clipsToBounds = YES;
    
    //添加视频播放完成的notifation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.playerLayer.frame = self.bounds;
}

#pragma mark - XHPlayer delegate

- (void)videoPlayer:(XHPlayer *)videoPlayer didStartLoadingAtItemTime:(CMTime)itemTime {
    
}

- (void)videoPlayer:(XHPlayer *)videoPlayer didEndLoadingAtItemTime:(CMTime)itemTime {
    
}

- (void)videoPlayer:(XHPlayer *)videoPlayer didPlay:(CMTime)timePlayed timeTotal:(CMTime)timeTotal {
	
}

- (void)videoPlayer:(XHPlayer *)videoPlayer didChangeItem:(AVPlayerItem *)item {
}

@end
