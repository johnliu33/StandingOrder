//  Created by Tai on 2010/11/17.
//  Copyright 2009 Cyberon Inc.. All rights reserved.
//

#import "StreamPlayer.h"

#define kBytesPerSample 2
#define kBitsPerChannel (kBytesPerSample * 8)


@implementation StreamPlayer

@synthesize delegate, isAbort = mIsAbort , isPause = mIsPause;

static void SetupAudioFormat(AudioStreamBasicDescription* recordFormat, int sampleRate)
{
	memset(recordFormat, 0, sizeof(*recordFormat));	
	recordFormat->mSampleRate = sampleRate;
	recordFormat->mChannelsPerFrame = 1;	
	recordFormat->mFormatID = kAudioFormatLinearPCM;
	recordFormat->mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
	recordFormat->mBitsPerChannel = kBitsPerChannel;
	recordFormat->mBytesPerPacket = recordFormat->mBytesPerFrame = kBytesPerSample;
	recordFormat->mFramesPerPacket = 1;
}

static void enqueueData(StreamPlayer *player, AudioQueueBufferRef inBuffer)
{	
	int nSample = player->mTotAddSample - player->mIdxPlay;
	
	// if there is not enough audio data to playback, add silence block
	if (!player->mIsEndOfData && nSample < player->mSamplePerBlk){
		memset(inBuffer->mAudioData, 0, sizeof(short) * player->mSamplePerBlk);
		inBuffer->mAudioDataByteSize = sizeof(short) * player->mSamplePerBlk;
		AudioQueueEnqueueBuffer(player->mQueue, inBuffer, 0, NULL);
		return;
	}
	
	if (nSample > player->mSamplePerBlk)
		nSample = player->mSamplePerBlk;
	
	int nByteSize = sizeof(short) * nSample;
    short *buff = (short *)[player->mSampleQueue bytes];
    memcpy(inBuffer->mAudioData, buff + player->mIdxPlay, nByteSize);
	
	// padding 0 if data cannot fill a block for the final block,
    // and always tell the AudioQueue there is a complete block of data to
    // playback, o/w the audio device may not play anything.
	if (nSample < player->mSamplePerBlk) {
        int n = sizeof(short) * player->mSamplePerBlk - nByteSize;
		memset(inBuffer->mAudioData + nByteSize, 0, n);
    }
	inBuffer->mAudioDataByteSize = sizeof(short) * player->mSamplePerBlk;
	
	// update play index
	player->mIdxPlay += nSample;
	
	// add a new buffer to the AudioQueue
	AudioQueueEnqueueBuffer(player->mQueue, inBuffer, 0, NULL);
}

static void HandleOutputBuffer(void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{
	StreamPlayer *player = (StreamPlayer *)aqData;
	
	// when playback finishes or AudioQueueStop is invoked, 
    // do not add buffers in audio queue any more.
	if (player->mFlushBuffer && player->mNumBufInQueue > 0){
		player->mNumBufInQueue--;
		if (player->mNumBufInQueue == 0 && !player->mIsAbort &&
			[player->delegate respondsToSelector:@selector(playFinish:)])
		{
			[player->delegate playFinish:player];
		}
		return;
	}
    
	// get a block of samples from circular queue and add it to AudioQueue buffer 
	enqueueData(player, inBuffer);
	
	// if the block enqueued above is the last one, start to flush buffer in audio queue.
	if (player->mIsEndOfData && player->mTotAddSample == player->mIdxPlay){
		player->mFlushBuffer = YES;
		AudioQueueStop(player->mQueue, false);
	}	
}

- (id)initWithSampleRate:(int)sampleRate samplePerBlock:(int)numBlkSample 
{
	if ((self = [super init])){
		AudioStreamBasicDescription recordFormat;
		
		SetupAudioFormat(&recordFormat, sampleRate);
		AudioQueueNewOutput(&recordFormat, HandleOutputBuffer,
                    self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &mQueue);
		
		mSampleRate = sampleRate;
		mSamplePerBlk = numBlkSample;
        mSampleQueue = [[NSMutableData alloc] init];
		
		mNumBufInQueue = 0;
		mFlushBuffer = NO;
		
		for(int i = 0; i < kNumberBuffers; i++)
			AudioQueueAllocateBuffer(mQueue, mSamplePerBlk * sizeof(short), &mQueueBuf[i]);
		
		[self reset];
	}
	
	return self;
}

-(void)dealloc
{	
	[self abort];
	
    [mSampleQueue release];
	
	for(int i = 0; i < kNumberBuffers; i++)
		AudioQueueFreeBuffer(mQueue, mQueueBuf[i]);
	
	if (mQueue)
		AudioQueueDispose(mQueue, true);
	
	[super dealloc];
}

- (int)addSample:(short*)sample numberOfSample:(int)numSample 
{	
	if (mIsEndOfData || mIsAbort)
		return 0;
	
    [mSampleQueue appendBytes:sample length:numSample*sizeof(short)];
    
	mTotAddSample += numSample;
    
	return numSample;
}

- (void)startPlay 
{
	// if audio queue is not initialized or is currently playing, then return immediately
	if (!mQueue || mIsAbort || mNumBufInQueue > 0)
		return;
	
	for(int i = 0; i < kNumberBuffers; i++){
		enqueueData(self, mQueueBuf[i]);
		mNumBufInQueue++;
	}
	mFlushBuffer = NO;
	AudioQueueStart(mQueue, NULL);
}

- (void)reset 
{	
    if (mQueue) {
		mIsAbort = YES;
		mFlushBuffer = YES;
		AudioQueueStop(mQueue, true);
	}
    
    [mSampleQueue setLength:0];
    
	mTotAddSample = 0;	
	mIdxPlay = 0;
	mIsEndOfData = NO;
	mIsAbort = NO;
}

- (void)endOfData 
{
	mIsEndOfData = YES;
}

- (void)abort 
{
	mIsEndOfData = YES;
	mIsAbort = YES;
    mFlushBuffer = YES;

    if (mQueue)
		AudioQueueStop(mQueue, true);
}

- (void)pause{
    mIsPause = YES;
    AudioQueuePause(mQueue);
}

- (void)resume{
    mIsPause = NO;
    AudioQueueStart(mQueue, NULL);
}


- (BOOL)enoughDataToPlay:(int)minNumSample 
{	
	if (mIsAbort || mIsEndOfData)
		return YES;
	
	if (mTotAddSample >= minNumSample)
		return YES;
	
	return NO;
}

@end
