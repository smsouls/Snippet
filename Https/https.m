/*
  使用https
 */


/*
 NSURLSessionAuthChallengePerformDefaultHandling  使用iOS系统的证书进行认证
 NSURLSessionAuthChallengeUseCredential           使用用户自制的证书进行认证
 */


/*
 NSURLAuthenticationMethodServerTrust   表示是要求验证服务器端证书是否合法
 */
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if (self.sessionDidReceiveAuthenticationChallenge) {
        disposition = self.sessionDidReceiveAuthenticationChallenge(session, challenge, &credential);
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if (credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}




/*
 在对服务器证书进行验证的时候采用的策略
 */
[policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
[policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);

/*
 添加自制证书到系统的锚点证书
 */
SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);


/*
 验证服务器证书是否是合法的
 */
SecTrustResultType result;
SecTrustEvaluate(serverTrust, &result);
(result == kSecTrustResultUnspecified || result == kSecTrustResultProceed)


/*
 获取服务器的证书链,一直到这个证书的根CA  a->b->c
 */
CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];

for (CFIndex i = 0; i < certificateCount; i++) {
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
    [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
}

/*
 获取服务器证书链的公钥,有时候不一定需要证书完全一致,只需要公钥一致就行了
 */
SecPolicyRef policy = SecPolicyCreateBasicX509();
CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
for (CFIndex i = 0; i < certificateCount; i++) {
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
    
    SecCertificateRef someCertificates[] = {certificate};
    CFArrayRef certificates = CFArrayCreate(NULL, (const void **)someCertificates, 1, NULL);
    
    SecTrustRef trust;
    SecTrustCreateWithCertificates(certificates, policy, &trust);
    
    SecTrustResultType result;
    SecTrustEvaluate(trust, &result);
    
    [trustChain addObject:(__bridge_transfer id)SecTrustCopyPublicKey(trust)];
}

    
/*
 虽然合法也可能是因为中间人的合法证书,如果我只允许我自己的证书则需要比较证书
 */
for (NSData *trustChainCertificate in [serverCertificates reverseObjectEnumerator]) {
    if ([self.pinnedCertificates containsObject:trustChainCertificate]) {
        return YES;
    }
}

/*
 比较公钥是否一致
 */
NSUInteger trustedPublicKeyCount = 0;
NSArray *publicKeys = AFPublicKeyTrustChainForServerTrust(serverTrust);

for (id trustChainPublicKey in publicKeys) {
    for (id pinnedPublicKey in self.pinnedPublicKeys) {
        if (AFSecKeyIsEqualToKey((__bridge SecKeyRef)trustChainPublicKey, (__bridge SecKeyRef)pinnedPublicKey)) {
            trustedPublicKeyCount += 1;
        }
    }
}


/*
 验证域是否满足
 */
let protectionSpace = challenge.protectionSpace
guard protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
protectionSpace.host.contains("example.com") else {
    completionHandler(.performDefaultHandling, nil)
    return
}








