//
//  ZoomVideoSDKNetworkConnectionHelper.h
//  ZoomVideoSDK
//
//  Created by Zoom on 2022/9/2.
//  Copyright © 2022 Zoom Video Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class ZoomVideoSDKProxySettingHandler
 */

@interface ZoomVideoSDKProxySettingHandler : NSObject

/*!
 @brief Get the address of the proxy host.
 */
@property (nonatomic, copy, readonly) NSString* proxyHost;

/*!
 @brief Get the proxy port.
 */
@property (nonatomic, assign, readonly) NSInteger proxyPort;

/*!
 @brief Get the description of the proxy.
 */
@property (nonatomic, copy, readonly) NSString* proxyDescription;

/*!
 @brief Input the username and password when using the proxy.
 @param userName The username when using the proxy.
 @param psw The password when using the proxy.
 */
- (void)inputUsername:(NSString *)userName password:(NSString *)psw;

/*!
 @brief Cancel the process to input the username and password of the proxy.
 */
- (void)cancel;

@end

/*!
 @class ZoomVideoSDKSSLCertVerifiedFailHandler
 */

@interface ZoomVideoSDKSSLCertificateInfo : NSObject

/*!
 @brief Get the value of whom the SSL certificate is issued to.
 */
@property (nonatomic, copy, readonly) NSString* certIssuedTo;

/*!
 @brief Get the value that who issues the SSL certificate.
 */
@property (nonatomic, copy, readonly) NSString* certIssuedBy;

/*!
 @brief Get the serial number of the SSL certificate.
 */
@property (nonatomic, copy, readonly) NSString* certSerialNum;

/*!
 @brief Get the SSL certificate's fingerprint
 */
@property (nonatomic, copy, readonly) NSString* certFingerprint;


@end



