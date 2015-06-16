//  Created by Leo on 2009/11/26.
//  Copyright 2009 Cyberon Inc.. All rights reserved.
//

#import "AQPlayer.h"


@implementation AQPlayer
@synthesize isRun= mIsRun;
#define kNumberBuffers 3
#define k_nBytesPerSample 2
#define k_nBitsPerChannel (k_nBytesPerSample* 8)
#define k_nBufferSize 512
void SetupAudioFormat(AudioStreamBasicDescription* recordFormat, int sampleRate)
{
	memset(recordFormat, 0, sizeof(*recordFormat));	
	recordFormat->mSampleRate= sampleRate;
	recordFormat->mChannelsPerFrame=1;	
	recordFormat->mFormatID = kAudioFormatLinearPCM;
	recordFormat->mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
	recordFormat->mBitsPerChannel = k_nBitsPerChannel;
	recordFormat->mBytesPerPacket = recordFormat->mBytesPerFrame = k_nBytesPerSample;
	recordFormat->mFramesPerPacket = 1;
}

-(void)releaseResource:(BOOL)immediate{
	if(mQueue!= nil) {
		AudioQueueDispose(mQueue, immediate);
		mQueue= nil;
	}
	if(mWaveData!= nil){
		[mWaveData release];
		mWaveData= nil;
	}
}

-(void)abort{
	[self releaseResource: YES];
	mIsRun= NO;
}

static void enqueueData(AQPlayer* player, AudioQueueBufferRef  inBuffer){
	int count= [player->mWaveData length]- player->mDataPointer;
	if(count> inBuffer->mAudioDataBytesCapacity) count= inBuffer->mAudioDataBytesCapacity;
	if(count<= 0) return;
	[player->mWaveData getBytes: inBuffer->mAudioData range: NSMakeRange(player->mDataPointer, count)];
	inBuffer->mAudioDataByteSize= count;
	player->mDataPointer+= count;
	AudioQueueEnqueueBuffer(player->mQueue, inBuffer, 0, NULL);
	player->mBufferCount++;
}

static void HandleOutputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef  inBuffer){
	AQPlayer* player= (AQPlayer*) aqData;
	if(!player->mIsRun) return;
	player->mBufferCount--;
	enqueueData(player, inBuffer);
	if(player->mBufferCount<= 0){
		[player releaseResource: NO];
		player->mIsRun= NO;
	}		
}

#define kAQExceptionName @"Audio queue player exception"
void throwIfError(int errorCode){
	if(errorCode!= 0)
		[NSException raise:kAQExceptionName format: @"Error code:%i", errorCode];
}

-(void)Play:(NSData*) wavData andSampleRate: (int) sampleRate{
	AudioStreamBasicDescription recordFormat;
	if(mIsRun) {
		[self abort];
	}
	if([wavData length]<= k_nBufferSize* kNumberBuffers/2+ 1) return; //wave data too short, ignore
	mWaveData= [wavData retain];
	mDataPointer= 0;
	mBufferCount= 0;
	@try{
		SetupAudioFormat(&recordFormat, sampleRate);
		throwIfError(AudioQueueNewOutput(&recordFormat, HandleOutputBuffer,	self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &mQueue));
		mIsRun= YES;
		for (int i = 0; i < kNumberBuffers&& mDataPointer< [mWaveData length]; i++) {
			AudioQueueBufferRef	buffer;
			throwIfError(AudioQueueAllocateBuffer(mQueue, k_nBufferSize, &buffer));
			enqueueData(self, buffer);
		}
		throwIfError(AudioQueueStart(mQueue, NULL));
	}@catch(...){
		[self releaseResource: NO];
		@throw;
	}
}

-(void)dealloc{
	[self releaseResource: NO];
	[super dealloc];
}
@end
