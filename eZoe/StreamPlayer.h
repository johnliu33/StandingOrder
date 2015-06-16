//  Created by Tai on 2010/11/17.
//  Copyright 2009 Cyberon Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h> 

#define kNumberBuffers	6

@interface StreamPlayer : NSObject {
	
	AudioQueueRef	mQueue;	
	AudioQueueBufferRef mQueueBuf[kNumberBuffers];
	
	// var for the circular queue
	int		mSampleRate;		// sample rate for the data to be played
	int		mSamplePerBlk;		// number of sample for each block
    NSMutableData* mSampleQueue;// buffer for the sample queue
	
	// var for indices and amount of add and played samples, and number of blocks in audio queue
	int		mIdxPlay;			// the index of audio data to be played next time
	int		mTotAddSample;		// total number of samples added 
	int		mNumBufInQueue;		// number of bufferscurrently in audio queue
	
	// flag to control the callback function
	BOOL	mIsEndOfData;		// YES when there is no more data that can be added
	BOOL	mIsAbort;			// YES if abort functions are called, and callback stops enqueueing
    BOOL	mIsPause;			// YES if pause functions are called, and callback pause enqueueing
	BOOL	mFlushBuffer;		// YES then callback will not enqueue any more
	
	id		delegate;			// delegate from caller
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) BOOL isAbort;
@property (nonatomic, readonly) BOOL isPause;

- (id)initWithSampleRate:(int)sampleRate samplePerBlock:(int)numBlkSample;
- (int)addSample:(short*)sample numberOfSample:(int)numSample;
- (void)reset;				// reset vars, call this function before adding sample
- (void)startPlay;			// inform audio device to start play
- (void)abort;				// stop playing immediately
- (void)pause;				// pause playing immediately
- (void)resume;				// resume playing immediately
- (void)endOfData;			// inform audio device no more data will be added
- (BOOL)enoughDataToPlay:(int)minNumSample;	// return YES if added data is enough to init the AudioQueue buffers

@end


@protocol StreamPlayerDelegate 
@optional
- (void)playFinish:(id)sender;	// called by StreamPlayer when it finishes the playback normally
@end
