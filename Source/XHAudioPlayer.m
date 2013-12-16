//
//  XHAudioPlayer.m
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-16.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import "XHAudioPlayer.h"

@implementation XHAudioPlayer
@synthesize audioPlayer=_audioPlayer;
@synthesize audioRecorder=_audioRecorder;
@synthesize timer=_timer;
@synthesize delegate=_delegate;


- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)resetAudioPlayer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    if (_audioRecorder) {
        [_audioRecorder stop];
        [_audioRecorder setDelegate:nil];
        _audioRecorder = nil;
    }
}

- (void)dealloc {
    if (_audioPlayer) {
        [_audioPlayer stop];
        [_audioPlayer setDelegate:nil];
        _audioPlayer = nil;
    }
    [self resetAudioPlayer];
}

- (void)playFileData:(NSData *)data {
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    if (_timer) {
        _timer = nil;
    }
    
    if (data && [data isKindOfClass:[NSData class]]) {
        NSError *error = [[NSError alloc] init];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:&error];
        player.meteringEnabled = YES;
        
        if (!player) {
            //handle error
            NSLog(@"Failed to play ");
        } else {
            error = nil;
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
            
            if(error) {
                NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
            }
            
            player.delegate = self;
            self.audioPlayer = player;
            _audioPlayer.numberOfLoops = 0;
            [_audioPlayer prepareToPlay];
            [_audioPlayer play];
            
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
            [timer fire];
            self.timer = timer;
        }
    }
    
}

- (void)playFile:(NSString *)strFilePath {
    NSData * data = [[NSData alloc] initWithContentsOfFile:strFilePath];
    [self playFileData:data];
}

- (void)playFileOnline:(NSString *)strUrl {
    NSURL * url = [NSURL URLWithString:strUrl];
    NSData * data = [NSData dataWithContentsOfURL:url];
    [self playFileData:data];
    
}

- (void)recordTo:(NSString *)strFilePath {
    if (_audioRecorder) {
        [_audioRecorder stop];
        _audioRecorder = nil;
    }
    
    
    NSURL *destinationURL = [NSURL fileURLWithPath:strFilePath];
    NSError *error;
    
    AVAudioRecorder * recorder = [[AVAudioRecorder alloc]initWithURL:destinationURL settings:nil error:&error];
    
    if (!recorder) {
        //handle error
        NSLog(@"Failed to record %@",strFilePath);
    } else {
        recorder.delegate = self;
        self.audioRecorder = recorder;
        [recorder prepareToRecord];
        [recorder record];
    }
}

- (void)onTimer:(NSTimer *)timer {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(XHAudioPlayer:onProgress:)]) {
            [self.delegate XHAudioPlayer:self onProgress:_audioPlayer.currentTime/_audioPlayer.duration];
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_timer invalidate];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(XHAudioPlayer:didPlayFinish:)]) {
            [self.delegate XHAudioPlayer:self didPlayFinish:1];
        }
    }
}

@end
