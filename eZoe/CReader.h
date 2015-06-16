//
//  CReader.h
//  CReader
//
//  Created by Ulysses on 2011/11/4.
//  Copyright (c) 2011年 Cyberon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CReaderDelegate;

typedef enum
{
	CREADER_STATE_PARAM_ERROR = -100,
	CREADER_STATE_SYNTH_STARTED,
	CREADER_STATE_SYNTH_STOP,
	CREADER_STATE_FAILED,
	CREADER_STATE_LEXMGR_FAILED,
	CREADER_STATE_LOAD_BINS_FAILED,
    CREADER_STATE_EXPIRED,
	CREADER_STATE_SUCCESS = 0,
    
} CREADER_STATE_CODE;


typedef enum
{
	CREADER_LANG_CHT,		// CHT only
	CREADER_LANG_CHT_ENG,	// CHT and ENG
	CREADER_LANG_ENG,		// ENG only
	CREADER_LANG_JPN,		// JPN only
	CREADER_LANG_JPN_ENG,	// JPN and ENG
	
} CREADER_LANG_TYPE;


#pragma mark - CReader definition

@interface CReader : NSObject

/** ----------------------------------------------------------------------------------
 Creates and returns a CReader object. The object is autoreleased. Retain it for further use.
 
 Parameters:
 ttsBinFilesArray: array pointer of NSString objects keeps the paths of binary files for
 every language. A language contains two binary files: prosody and synthizer.
 For exmaple, if the language setting is CREADER_LANG_CHT_ENG, the order of paths
 will be: prosody_CHT, synthizer_CHT, prosody_ENG, and synthizer_ENG.
 If the language setting is CREADER_LANG_CHT, the order of paths will be:
 prosody_CHT and synthizer_CHT. Note that the order is important.
 lang: one of CREADER_LANG_TYPE value to assign language setting.
 delegate: delegate "CReaderDelegate" for callback. 
 err: return the value of CREADER_STATE_CODE to indicate error code.
 
 Return nil if data file open failed or some errors occurred.
 */
+(CReader*) CReaderWithBinFiles:(NSString **)ttsBinFilesArray andLang:(CREADER_LANG_TYPE)lang
                    andDelegate:(id <CReaderDelegate>)delegate andError:(int *)err;


/** ----------------------------------------------------------------------------------
 Get the number of available language.
 
 Return the number of available language. The value must be larger than zero.
 */
-(int) numOfLanguage;


/** ----------------------------------------------------------------------------------
 Synthesis user's texts directly, not using callback function.
 The function will be blocking.
 
 Parameters:
 uttr: text for synthesis.
 
 Return the buffer of synthesis audio. nil if error occurs.
 */
-(NSData *) generateTTS:(NSString *)uttr;


/** ----------------------------------------------------------------------------------
 Starts to synthesis user's texts. The generated TTS audio can be received
 from the delegate "CReaderDelegate".
 
 Parameters:
 uttr: text for synthesis.
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(int) start:(NSString*)uttr;


/** ----------------------------------------------------------------------------------
 Stop action of synthesis.
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(int) stop;

/** ----------------------------------------------------------------------------------
 Pasue action of synthesis.
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(void) pause;

/** ----------------------------------------------------------------------------------
 Resume action of synthesis.
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(void) resume;




/** ----------------------------------------------------------------------------------
 check if CReader engine synthesis done.
 
 Return YES if synthesis finished. Otherwise NO.
 */
-(BOOL) isSynthStop;


/** ----------------------------------------------------------------------------------
 Set the speed of synthesised audio.
 The range is between 50 and 200. Default value is 100. 
 The larger value, the slower speed.
 
 Parameters:
 speedArray: integer array for every available language respectively.
 If the value is negative, not change the setting of engine.
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(int) setSpeed:(int *)speedArray;


/** ----------------------------------------------------------------------------------
 Set the base f0 level of synthesised audio.
 The range is between 50 and 200. Default value is 100. 
 The larger value, the higher pitch(frequency).
 
 Parameters:
 f0Array: integer array for every available language respectively.
 If the value is negative, not change the setting of engine.
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(int) setBaseF0:(int *)f0Array;


/** ----------------------------------------------------------------------------------
 Set the long delay value of synthesised audio. Unit is milli-second.
 The long delay is for pronunciation characters including "，", "。", and "！". 
 The default value is 600.
 
 Parameters:
 delayArray: integer array for every available language respectively.
 If the value is negative, not change the setting of engine. 
 Zero value can be set to disable long delay.
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(int) setLongDelay:(int *)delayArray;


/** ----------------------------------------------------------------------------------
 Set the short delay value of synthesised audio. Unit is milli-second.
 The short delay is for characters that not includes in long delay.
 The default value is 200.
 
 Parameters:
 delayArray: integer array for every available language respectively.
 If the value is negative, not change the setting of engine. 
 Zero value can be set to disable short delay.
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(int) setShortDelay:(int *)delayArray;


/** ----------------------------------------------------------------------------------
 Set the length of silence that append to beginning of phrase. Unit is milli-second.
 The default value is dependent on Long Delay value.
 
 Parameters:
 silArray: integer array for every available language respectively.
 If the value is less than -1, not change the setting of engine. 
 Value set to -1, silFront value will be dependent on Long Delay value.
 If value is equal or more than zero, silFront value will be set.
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(int) setSilFront:(int *)silArray;


/** ----------------------------------------------------------------------------------
 Set the length of silence that append to end of phrase. Unit is milli-second.
 The default value is dependent on Long Delay value.
 
 Parameters:
 silArray: integer array for every available language respectively.
 If the value is less than -1, not change the setting of engine. 
 Value set to -1, silBack value will be dependent on Long Delay value.
 If value is equal or more than zero, silBack value will be set.
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(int) setSilBack:(int *)silArray;


/** ----------------------------------------------------------------------------------
 Set the volume level of synthesised audio.
 The range is between 0 and 500. Default value is 100. 
 
 Parameters:
 volArray: integer array for every available language respectively.
 If the value is less than 0, not change the setting of engine. 
 
 Return CREADER_STATE_SUCCESS if success, otherwise error occurs.
 */
-(int) setVolume:(int *)volArray;


@end


#pragma mark - CReaderDelegate definition

@protocol CReaderDelegate <NSObject>

/**
 Sent when CReader engine generated audio data clip ready.(required)
 
 Parameters:
 audio: Audio sample buffer. Use the audio data in short data-type.
 
 Note: The callback should return as soon as possible.
 */
-(void) onCReaderSynthProgress:(NSData *)audio;

@optional

/**
 Sent when CReader engine synthesis is starting.(optional)
 
 Parameters:
 sender: object of CReader.
 */
-(void) onCReaderSynthBegin:(CReader *)sender;

/**
 Sent when CReader engine synthesis is finish. But the method 
 "onCReaderSynthProgress" may send continuely.(optional)
 
 Parameters:
 sender: object of CReader.
 */
-(void) onCReaderSynthFinish:(CReader *)sender;

@end
