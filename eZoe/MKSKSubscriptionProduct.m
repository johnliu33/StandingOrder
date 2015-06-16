//
//  MKSKSubscriptionProduct.m
//  MKStoreKit (Version 5.0)
//
//  Created by Mugunth Kumar (@mugunthkumar) on 04/07/11.
//  Copyright (C) 2011-2020 by Steinlogic Consulting And Training Pte Ltd.

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website
//	2) or crediting me inside the app's credits page
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com


#import "MKSKSubscriptionProduct.h"
#import "NSData+Base64.h"
#if ! __has_feature(objc_arc)
#error MKStoreKit is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#ifndef __IPHONE_5_0
#error "MKStoreKit uses features (NSJSONSerialization) only available in iOS SDK  and later."
#endif

@implementation MKSKSubscriptionProduct

-(id) initWithProductId:(NSString*) aProductId subscriptionDays:(int) days
{
  if((self = [super init]))
  {
    self.productId = aProductId;
    self.subscriptionDays = days;
  }
  self.isAutoRenewable = (self.subscriptionDays == -1);   
  return self;
}

- (void) verifyReceiptOnComplete:(void (^)(NSNumber*)) completionBlock
                         onError:(void (^)(NSError*)) errorBlock
{        
  self.onSubscriptionVerificationCompleted = completionBlock;
  self.onSubscriptionVerificationFailed = errorBlock;
  
  NSURL *url = [NSURL URLWithString:kReceiptValidationURL];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                        timeoutInterval:60];
	
	[theRequest setHTTPMethod:@"POST"];		
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
  NSString *receiptString = [NSString stringWithFormat:@"{\"receipt-data\":\"%@\" \"password\":\"%@\"}", [self.receipt base64EncodedString], kSharedSecret];        
    //NSLog(@"receipt:%@",receiptString);
	NSString *length = [NSString stringWithFormat:@"%d", [receiptString length]];	
	[theRequest setValue:length forHTTPHeaderField:@"Content-Length"];	
	
	[theRequest setHTTPBody:[receiptString dataUsingEncoding:NSUTF8StringEncoding]];
	
  self.theConnection = [NSURLConnection connectionWithRequest:theRequest delegate:self];  
  [self.theConnection start];
}

-(BOOL) isSubscriptionActive
{
    return NO;
/*
  if(!self.receipt) return NO;
    //20121217 johnliu
    if (self.isAutoRenewable) {
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSNumber *statusNumber = [self.verifiedReceiptDictionary objectForKey:@"status"];
        appDelegate.auto_renew_status = statusNumber;
        NSLog(@"receipt status:%d",[appDelegate.auto_renew_status integerValue]);
        if([statusNumber integerValue] == 0)
        {
            NSTimeInterval expiresDate = [[[self.verifiedReceiptDictionary objectForKey:@"latest_receipt_info"] objectForKey:@"expires_date"] doubleValue]/1000.0;
            NSDate* _expiresDate = [NSDate dateWithTimeIntervalSince1970:expiresDate];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            NSString *_expd = [formatter stringFromDate:_expiresDate];
            appDelegate.expireDate = _expd;
            NSLog(@"expires date:%@",appDelegate.expireDate);
        }
        return statusNumber && [statusNumber intValue] == 0;
    }
*/
}


#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{	
  self.dataFromConnection = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
	[self.dataFromConnection appendData:data];
}

-(NSDictionary*) verifiedReceiptDictionary {
  
  return [NSJSONSerialization JSONObjectWithData:self.receipt options:NSJSONReadingAllowFragments error:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  self.receipt = [self.dataFromConnection copy];
    NSString *strData = [[NSString alloc]initWithData:self.receipt encoding:NSUTF8StringEncoding];
    //NSLog(@"receipt data:%@",strData);
  if(self.onSubscriptionVerificationCompleted)
  {
    self.onSubscriptionVerificationCompleted([NSNumber numberWithBool:[self isSubscriptionActive]]);
    self.dataFromConnection = nil;
  }
  
  self.onSubscriptionVerificationCompleted = nil;
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
  self.dataFromConnection = nil;
  if(self.onSubscriptionVerificationFailed)
    self.onSubscriptionVerificationFailed(error);
  
  self.onSubscriptionVerificationFailed = nil;
}

@end
