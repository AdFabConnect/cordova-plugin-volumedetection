/*
The MIT License (MIT)

Copyright (c) 2014 AdFab Connect

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */
//
//  VolumeDetectionPhonegap.m
//  HelloWorld
//
//  Created by Adfab connect on 07/01/2014.
//
//

#import "VolumeDetectionPhonegap.h"

@implementation VolumeDetectionPhonegap

- (void)init:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    
    thread = [NSThread currentThread];
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 0],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    /*[self.commandDelegate runInBackground:^{
        [self start];
    }];
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    */
    
}

- (void)start:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [self start];
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
}

- (void)start
{
    
    
    if (recorder) {
        //recorder.delegate = self;
        [recorder prepareToRecord];
        recorder.meteringEnabled = TRUE;
        [recorder record];
    } else {
        NSLog(@"");// mic error message
    }
}

- (void)stop:(CDVInvokedUrlCommand*)command
{
    //NSLog(@"stop");
    [self.commandDelegate runInBackground:^{
        [timer invalidate];
        [recorder stop];
    }];
}

- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (ALPHA * [recorder averagePowerForChannel:0]));
    double db = 20* log10(peakPowerForChannel);
    db += 50;
    db = db < 0 ? 0 : db;
    
    //float lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:db];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];

}

@end
