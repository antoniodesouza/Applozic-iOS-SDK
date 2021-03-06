//
//  ALResponseHandler.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALResponseHandler.h"
#import "NSData+AES.h"
#import "ALUserDefaultsHandler.h"

@implementation ALResponseHandler

#define message_SomethingWentWrong @"SomethingWentWrong"

+(void)processRequest:(NSMutableURLRequest *)theRequest andTag:(NSString *)tag WithCompletionHandler:(void (^)(id, NSError *))reponseCompletion
{
    
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSHTTPURLResponse * theHttpResponse = (NSHTTPURLResponse *) response;

        NSLog(@"ERROR_RESPONSE : %@ && ERROR:CODE : %ld ", connectionError.description, (long)connectionError.code);
        
        if(connectionError.code == kCFURLErrorUserCancelledAuthentication)
        {
            NSLog(@"HTTP:401 : ERROR CODE : %ld",  (long)connectionError.code);
        }
        if(connectionError.code == kCFURLErrorNotConnectedToInternet)
        {
            NSLog(@"NO INTERNET CONNECTIVITY ERROR CODE : %ld",  (long)connectionError.code);
        }
        
        //connection error
        if (connectionError)
        {
            reponseCompletion(nil,[self errorWithDescription:@"Unable to connect with the server. Check your internet connection and try again"]);
            return;
        }
        
        if (theHttpResponse.statusCode != 200)
        {
            NSMutableString * errorString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"api error : %@ - %@",tag,errorString);
            reponseCompletion(nil,[self errorWithDescription:message_SomethingWentWrong]);
            return;
        }
        
        if (data == nil)
        {
            reponseCompletion(nil,[self errorWithDescription:message_SomethingWentWrong]);
            NSLog(@"api error - %@",tag);
            return;
        }
        
       id theJson = nil;
       
       // DECRYPTING DATA WITH KEY
       if([ALUserDefaultsHandler getEncryptionKey] && ![tag isEqualToString:@"CREATE ACCOUNT"] && ![tag isEqualToString:@"CREATE FILE URL"])
       {
           NSData *base64DecodedData = [[NSData alloc] initWithBase64EncodedData:data options:0];
           NSData *theData = [base64DecodedData AES128DecryptedDataWithKey:[ALUserDefaultsHandler getEncryptionKey]];
           data = theData;
       }
                              
        if ([tag isEqualToString:@"CREATE FILE URL"] || [tag isEqualToString:@"IMAGE POSTING"])
        {
            theJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            /*TODO: Right now server is returning server's Error with tag <html>.
             it should be proper jason response with errocodes.
             We need to remove this check once fix will be done in server.*/
            
            NSError * error = [self checkForServerError:theJson];
            if(error)
            {
                reponseCompletion(nil, error);
                return;
            }
        }
        else
        {
            NSError * theJsonError = nil;

            theJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&theJsonError];
           
            if (theJsonError)
            {
                NSMutableString * responseString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //CHECK HTML TAG FOR ERROR
                NSError * error = [self checkForServerError:responseString];
                if(error)
                {
                    reponseCompletion(nil, error);
                    return;
                }
                else
                {
                    reponseCompletion(responseString,nil);
                    return;
                }
            }
        }
        reponseCompletion(theJson,nil);
        
    }];
}

+(NSError *) errorWithDescription:(NSString *) reason
{
    return [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey]];
}

+(NSError * )checkForServerError:(NSString *)response
{
    if ([response hasPrefix:@"<html>"]|| [response isEqualToString:[@"error" uppercaseString]])
    {
        NSError *error = [NSError errorWithDomain:@"Internal Error" code:500 userInfo:nil];
        return error;
    }
    return NULL;
}

@end
