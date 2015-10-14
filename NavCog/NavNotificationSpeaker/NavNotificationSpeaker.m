/*******************************************************************************
 * Copyright (c) 2015 Chengxiong Ruan
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/

#import "NavNotificationSpeaker.h"
#import <AVFoundation/AVFoundation.h>

#define IS_IOS_9 ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion == 9)

@interface NavNotificationSpeaker ()

@property (strong, nonatomic) AVSpeechSynthesizer *avSpeaker;
@property (nonatomic) Boolean beFast;
@property (nonatomic) float fastRatio;
@property (nonatomic) float slowRatio;

@end

@implementation NavNotificationSpeaker

+ (instancetype)getInstance {
    static NavNotificationSpeaker *instance = nil;
    if (instance == nil) {
        instance = [[NavNotificationSpeaker alloc] init];
        instance.avSpeaker = [[AVSpeechSynthesizer alloc] init];
        instance.beFast = true;
        instance.fastRatio = IS_IOS_9 ? 1.7 : 4;
        instance.slowRatio = IS_IOS_9 ? 1.9 : 8;
    }
    return instance;
}

+ (void)setFastSpeechOnAndOff:(Boolean)isFast {
    NavNotificationSpeaker *instance = [NavNotificationSpeaker getInstance];
    instance.beFast = isFast;
}

+ (void)speakWithCustomizedSpeed:(NSString *)str {
    NavNotificationSpeaker *instance = [NavNotificationSpeaker getInstance];
    if (instance.beFast) {
        [instance selfSpeak:str];
    } else {
        [instance selfSpeakSlowly:str];
    }
}

+ (void)speakWithCustomizedSpeedImmediately:(NSString *)str {
    NavNotificationSpeaker *instance = [NavNotificationSpeaker getInstance];
    if (instance.beFast) {
        [instance selfSpeakImmediately:str];
    } else {
        [instance selfSpeakImmediatelyAndSlowly:str];
    }
}

+ (void)speakImmediately:(NSString *)str {
    NavNotificationSpeaker *instance = [NavNotificationSpeaker getInstance];
    [instance selfSpeakImmediately:str];
}

+ (void)speak:(NSString *)str {
    NavNotificationSpeaker *instance = [NavNotificationSpeaker getInstance];
    [instance selfSpeak:str];
}

+ (void)speakImmediatelyAndSlowly:(NSString *)str {
    NavNotificationSpeaker *instance = [NavNotificationSpeaker getInstance];
    [instance selfSpeakImmediatelyAndSlowly:str];
}

+ (void)speakSlowly:(NSString *)str {
    NavNotificationSpeaker *instance = [NavNotificationSpeaker getInstance];
    [instance selfSpeakSlowly:str];
}

- (void)selfSpeakImmediately:(NSString *)str {
    if (_avSpeaker.speaking) {
        [_avSpeaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    AVSpeechUtterance *avUtterance = [[AVSpeechUtterance alloc] initWithString:str];
    [avUtterance setRate:AVSpeechUtteranceMaximumSpeechRate / _fastRatio];
    [avUtterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]];
    [avUtterance setVolume:1.0];
    [avUtterance setPitchMultiplier:1.0];
    [_avSpeaker speakUtterance:avUtterance];
}

- (void)selfSpeak:(NSString *)str {
    AVSpeechUtterance *avUtterance = [[AVSpeechUtterance alloc] initWithString:str];
    [avUtterance setRate:AVSpeechUtteranceMaximumSpeechRate / _fastRatio];
    [avUtterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]];
    [avUtterance setVolume:1.0];
    [avUtterance setPitchMultiplier:1.0];
    [_avSpeaker speakUtterance:avUtterance];
}

- (void)selfSpeakImmediatelyAndSlowly:(NSString *)str {
    if (_avSpeaker.speaking) {
        [_avSpeaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    AVSpeechUtterance *avUtterance = [[AVSpeechUtterance alloc] initWithString:str];
    [avUtterance setRate:AVSpeechUtteranceMaximumSpeechRate / _slowRatio];
    [avUtterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]];
    [avUtterance setVolume:1.0];
    [avUtterance setPitchMultiplier:1.0];
    [_avSpeaker speakUtterance:avUtterance];
}

- (void)selfSpeakSlowly:(NSString *)str {
    AVSpeechUtterance *avUtterance = [[AVSpeechUtterance alloc] initWithString:str];
    [avUtterance setRate:AVSpeechUtteranceMaximumSpeechRate / _slowRatio];
    [avUtterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]];
    [avUtterance setVolume:1.0];
    [avUtterance setPitchMultiplier:1.0];
    [_avSpeaker speakUtterance:avUtterance];
}

@end
