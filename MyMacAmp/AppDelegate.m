//
//  AppDelegate.m
//  MyMacAmp
//
//  Created by Michael Chadwick on 1/3/14.
//  Copyright (c) 2014 TestCo. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize audioStatus = _audioStatus;

-(id)init {
  self = [super init];
  if(self) {
    _audioStatus = AudioStopped;
  }
  return self;
}

#pragma mark - Application Event Handlers
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [self initialize];
  [self loadDefaults];
}
- (void)applicationWillTerminate:(NSNotification *)notification {
  [self soundStop];
}

#pragma mark - Window Delegate Event Handlers
- (void)windowWillClose:(NSNotification *)notification {
  [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - Sound Delegate Event Handlers
- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)aBool {
  if ([_loopToggle state] == NSOffState) {
    _audioStatus = AudioStopped;
    [self.audioStatusText setStringValue:@"AudioStopped"];
  }
}

#pragma mark - Private Methods
- (NSString*)getAudioFileFromDialog {
  NSInteger result;
  NSOpenPanel *oPanel = [NSOpenPanel openPanel];
  NSArray *filesToOpen;
  NSString *theNewFilePath;
  NSMutableArray *fileTypes = [NSMutableArray arrayWithArray:[NSSound soundUnfilteredTypes]];

  [oPanel setAllowsMultipleSelection:NO];
  [oPanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
  oPanel.allowedFileTypes = fileTypes;

  result = [oPanel runModal];

  if (result == NSModalResponseOK) {
    filesToOpen = [oPanel URLs];
    theNewFilePath = [filesToOpen objectAtIndex:0];
    NSLog(@"Sound file is now: %@", theNewFilePath);
    audioFilePath = theNewFilePath;
    [self updateSoundFile:false];
    return theNewFilePath;
  } else return audioFilePath;
}
- (void)updateSoundFile:(bool)isLocal {
  if (audioFilePath) {
    if (isLocal) {
      [audioFile stop];
      audioFile = [NSSound soundNamed:audioFilePath];
    } else {
      if([audioFilePath isKindOfClass:[NSURL class]]) {
        [audioFile stop];
        audioFile = [[NSSound alloc] initWithContentsOfURL:(NSURL*) audioFilePath byReference:YES];
      } else {
        if(audioFilePath.length > 0) {
          [audioFile stop];
          audioFile = [[NSSound alloc] initWithContentsOfFile:audioFilePath byReference:YES];
        }
      }
    }

    [audioFile setDelegate:self];
    [audioFile setVolume:_volumeSlider.floatValue];

    [self soundStop];

    [self updateField:self.audioFileText withString:audioFilePath];
    [self updateDuration:[audioFile duration]];
  } else {
    NSLog(@"audioFilePath is nil or blank");
  }
}
- (void)updateField:(NSTextField*)textField withString:(NSString*)path {
  NSString* newText = [[path pathComponents] objectAtIndex:[[path pathComponents] count]-1];
  [textField setStringValue:newText];
}

- (void)initialize {
  // initial load make the volume maxed
  [self.volumeSlider setFloatValue:1.0];

  // Load System Sounds Popup with system sounds
  [_systemSoundsPopUp addItemsWithTitles:[NSSound systemSounds]];
  [_systemSoundsPopUp insertItemWithTitle:@"" atIndex:0];
  [_systemSoundsPopUp selectItemAtIndex:0];
  [_customSoundText setEnabled:false];

  [_window setDelegate:self];
  [_window setDefaultButtonCell:nil];
}
- (void)loadDefaults {
  audioFilePath = @"loop.wav";
  [self updateSoundFile:true];
  [self updateElapsed];
}
- (void)soundStop {
  [audioFile stop];
  _audioStatus = AudioStopped;
  [self.audioStatusText setStringValue:@"AudioStopped"];
}
- (void)updateElapsed {
  NSInteger curTimeInt = (NSInteger)audioFile.currentTime;
  NSInteger seconds = curTimeInt;
  NSInteger minutes = (curTimeInt / 60) % 60;

  NSString *curElapsedTime = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];

  [_audioFileElapsedText setStringValue:curElapsedTime];
  [_progressSlider setIntegerValue:curTimeInt];
}
- (void)updateDuration:(NSTimeInterval)duration {
  NSInteger ti = (NSInteger)duration;
  NSInteger seconds = ti % 60;
  NSInteger minutes = (ti / 60) % 60;
  [_audioFileDurationText setStringValue:[NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds]];
  _progressSlider.maxValue = ti;
  [_progressSlider setIntegerValue:0];
}
- (void)updateLoopSetting {
  if ([_loopToggle state] == NSOnState) {
    audioFile.loops = YES;
  } else audioFile.loops = NO;
}

#pragma mark - IB GUI Event Handlers
- (IBAction)onPlayClick:(id)sender {
  if([audioFile isPlaying]) {
    [audioFile stop];
  }
  [self updateLoopSetting];

  timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateElapsed) userInfo:nil repeats:YES];

  [audioFile play];
  _audioStatus = AudioPlaying;
  [self.audioStatusText setStringValue:@"AudioPlaying"];

  //[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
- (IBAction)onPauseClick:(id)sender {
  if (_audioStatus == AudioPlaying) {
    [audioFile pause];
    _audioStatus = AudioPaused;
    [self.audioStatusText setStringValue:@"AudioPaused"];
  } else if (_audioStatus == AudioStopped) {
    [audioFile stop];
  } else {
    [audioFile resume];
    _audioStatus = AudioPlaying;
    [self.audioStatusText setStringValue:@"AudioPlaying"];
  }
}
- (IBAction)onStopClick:(id)sender {
  [self soundStop];
  [timer invalidate];
  timer = nil;
}
- (IBAction)onLoopToggle:(id)sender {
  [self updateLoopSetting];
}

- (IBAction)onVolumeSliderChange:(id)sender {
  [audioFile setVolume:_volumeSlider.floatValue];
}
- (IBAction)onProgressSliderChange:(id)sender {
  NSTimeInterval ti;
  ti = _progressSlider.integerValue;
  [audioFile setCurrentTime:ti];
}

- (IBAction)onSystemSoundsComboBoxChange:(id)sender {
  if ([[sender titleOfSelectedItem] isNotEqualTo:@""]) {
    [self soundStop];
    audioFilePath = [sender titleOfSelectedItem];
    [self updateSoundFile:true];
    [_customSoundText setStringValue:@""];
  }
}
- (IBAction)onCustomSoundBrowseBtnClick:(id)sender {
  NSString *customSoundPath;
  if ([customSoundPath = [self getAudioFileFromDialog] isNotEqualTo:@""]) {
    [self soundStop];
    [self updateField:self.customSoundText withString:customSoundPath];
    [_systemSoundsPopUp selectItemAtIndex:0];
  }
}
- (IBAction)onResetAudioFileBtnClick:(id)sender {
  [self loadDefaults];
}

@end
