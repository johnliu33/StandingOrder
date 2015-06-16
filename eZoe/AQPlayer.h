//  Created by Leo on 2009/11/26.
//  Copyright 2009 Cyberon Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h> 
@interface AQPlayer : NSObject {
	NSData* mWaveData;
	int mDataPointer;
	bool mIsRun;
	AudioQueueRef	mQueue;
	int mBufferCount;
}
-(void)abort;
-(void)Play:(NSData*) waveData andSampleRate:(int) sampleRate;
@property (readonly) bool isRun;
@end
