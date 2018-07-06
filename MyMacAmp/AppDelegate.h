//
//  AppDelegate.h
//  MyMacAmp
//
//  Created by Michael Chadwick on 1/3/14.
//  Copyright (c) 2014 TestCo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudio.h>
#import <CoreAudio/AudioHardware.h>
#import "SystemSounds.h"

enum AudioStatus {
  AudioStopped    = 0,
  AudioPlaying    = 1,
  AudioPaused     = 2
} typedef AudioStatus;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSSoundDelegate> {
  NSString *audioFilePath;
  NSSound *audioFile;
  NSTimer *timer;

  AudioStatus _audioStatus;
}

@property (readonly) AudioStatus audioStatus;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSButton *pauseButton;
@property (weak) IBOutlet NSButton *stopButton;
@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) IBOutlet NSSlider *progressSlider;

@property (weak) IBOutlet NSTextField *audioFileText;
@property (weak) IBOutlet NSTextField *audioFileElapsedText;
@property (weak) IBOutlet NSTextField *audioFileDurationText;

@property (weak) IBOutlet NSButton *loopToggle;
@property (weak) IBOutlet NSButton *resetButton;

@property (weak) IBOutlet NSTextField *audioStatusText;

@property (weak) IBOutlet NSPopUpButton *systemSoundsPopUp;
@property (weak) IBOutlet NSTextField *customSoundText;
@property (weak) IBOutlet NSButton *customSoundBrowseBtn;

@end
