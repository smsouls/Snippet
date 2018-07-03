/*
 1.使用tcp添加ssl
 */


#import "SakuraIO.h"
#import "SakuraTypes.h"
#import <Security/Security.h>

@interface SakuraIO () {
    BOOL _isConnected;
    NSString *_host;
    unsigned int _port;
    NSInputStream *_inStream;
    NSOutputStream *_outStream;
}
@end

@implementation SakuraIO

+ (instancetype _Nullable )ioWithHost:(NSString * _Nonnull)host on:(unsigned int)port {
    return [[self alloc] initWithHost:host on:port];
}

- (instancetype _Nullable )initWithHost:(NSString * _Nonnull)host on:(unsigned int)port {
    self = [super init];

    if (self) {
        _isConnected = NO;
        _host        = [host copy];
        _port        = port;
        _inStream    = nil;
        _outStream   = nil;
    }
    
    return self;
}

- (BOOL)connect {
    if (_isConnected) {
        return YES;
    }
    
    CFReadStreamRef   read_s;
    CFWriteStreamRef  write_s;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)_host, _port, &read_s, &write_s);
    _inStream = (__bridge NSInputStream *)read_s;

    [_inStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
                   forKey:NSStreamSocketSecurityLevelKey];
    
    NSDictionary *sslSettings =
    [NSDictionary dictionaryWithObjectsAndKeys:
     (id)kCFBooleanFalse, (id)kCFStreamSSLValidatesCertificateChain,
     (id)kCFNull, (id)kCFStreamSSLPeerName,
     nil];
    
    
    [_inStream setProperty: sslSettings forKey: (__bridge NSString *)kCFStreamPropertySSLSettings];
    
    _outStream = (__bridge NSOutputStream *)write_s;
    _inStream.delegate = self;
    _outStream.delegate = self;
    
    
    [_inStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [_outStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    [_inStream open];
    [_outStream open];
    
    _isConnected = YES;
    
    return _isConnected;
}

- (BOOL)close {
    
    if (_inStream && _outStream) {
        
        [_inStream close];
        [_outStream close];
        
        [_inStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_outStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        [_inStream release];
        [_outStream release];
        
        _inStream = nil;
        _outStream = nil;
    }
    
    _isConnected = NO;
    
    return YES;
}

- (void)sendMessage:(Protocol_Class *)message {
    NSData *data = [message data];
    UInt16 length = CFSwapInt16HostToBig(data.length);
    NSMutableData *packet =[NSMutableData dataWithBytes:&length length:sizeof(UInt16)];
    [packet appendData:data];
    if ([_outStream write:packet.bytes maxLength:packet.length] > 0) {
        [_delegate onSnd:message error:nil];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"write error，probably connection has closed", @"desc", nil];
        [_delegate onSnd:message error:[NSError errorWithDomain:@"SakuraHttpClient" code:-1  userInfo:userInfo]];
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventNone:
            //none
            NSLog(@"[Event]none");
            break;
        case NSStreamEventOpenCompleted:
            //connection open
            NSLog(@"[Event]connection open");
            break;
        case NSStreamEventHasBytesAvailable:
            //bytes available
            NSLog(@"[Event]bytes available");
            [self readBytes];
            break;
        case NSStreamEventHasSpaceAvailable:
            //space available
            [self addTurst:aStream];
            NSLog(@"[Event]space available");
            break;
        case NSStreamEventErrorOccurred:
            //connection error
            NSLog(@"[Event]connection error");
            NSError * thisErr = [aStream streamError];
            [_delegate onErr:thisErr];
            break;
        case NSStreamEventEndEncountered:
            //connection close
            NSLog(@"[Event]connection close");
            [_delegate onClose];
            break;
    }
}


- (void)readBytes {
    while ([_inStream hasBytesAvailable]) {
        uint8_t lenBuf[2];
        NSInteger readLength = [_inStream read: lenBuf maxLength:sizeof(lenBuf)];
        if (readLength < 0) {
            NSLog(@"read length error");
            if ([_inStream streamError]) {
                NSLog(@"stream error: %@", [_inStream streamError]);
            }
            break;
        }
        UInt16 length = CFSwapInt16BigToHost(*(uint16_t *)lenBuf);
        
        uint8_t dataBuf[length];
        readLength = [_inStream read: dataBuf maxLength: length];
        if (readLength < 0 || readLength != length) {
            NSLog(@"read data error");
            if ([_inStream streamError]) {
                NSLog(@"stream error: %@", [_inStream streamError]);
            }
            break;
        }
        
        NSData *data = [NSData dataWithBytes:dataBuf length:readLength];
        NSError *error = nil;
        Protocol_Class *message = [Protocol_Class parseFromData:data error:&error];
        if (error) {
            NSLog(@"parse protocol error, %@",error);
            break;
        }
        [_delegate onRecv: message];
    }
}


NSString *kAnchorAlreadyAdded = @"AnchorAlreadyAdded";

-(void)addTurst:(NSStream *)theStream{
    SecTrustRef trust = (SecTrustRef)([theStream propertyForKey: (__bridge NSString *)kCFStreamPropertySSLPeerTrust]);
    
    NSNumber *alreadyAdded = [theStream propertyForKey: kAnchorAlreadyAdded];
    if (!alreadyAdded || ![alreadyAdded boolValue]) {
        trust = addAnchorToTrust(trust, [self createCertificateFromFile:@"failed" fileType:@"der"]); // defined earlier.
        [theStream setProperty: [NSNumber numberWithBool: YES] forKey: kAnchorAlreadyAdded];
    }
    
    SecTrustResultType res = kSecTrustResultInvalid;    
    
    if (SecTrustEvaluate(trust, &res)) {
        [theStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [theStream setDelegate: nil];
        [theStream close];
        NSLog(@"-----1");
        return;
        
    }
    
    if (res != kSecTrustResultProceed && res != kSecTrustResultUnspecified) {
        [theStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [theStream setDelegate: nil];
        [theStream close];
        NSLog(@"-----2");
        return;
        
    }else {
        // Host is trusted.  Handle the data callback normally.
        NSLog(@"-----pass");
    }
}


SecTrustRef addAnchorToTrust(SecTrustRef trust, SecCertificateRef trustedCert)
{
#ifdef PRE_10_6_COMPAT
    CFArrayRef oldAnchorArray = NULL;
    
    /* In OS X prior to 10.6, copy the built-in
     anchors into a new array. */
    if (SecTrustCopyAnchorCertificates(&oldAnchorArray) != errSecSuccess) {
        /* Something went wrong. */
        return NULL;
    }
    
    CFMutableArrayRef newAnchorArray = CFArrayCreateMutableCopy(
                                                                kCFAllocatorDefault, 0, oldAnchorArray);
    CFRelease(oldAnchorArray);
#else
    /* In iOS and OS X v10.6 and later, just create an empty
     array. */
    CFMutableArrayRef newAnchorArray = CFArrayCreateMutable (
                                                             kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
#endif
    
    CFArrayAppendValue(newAnchorArray, trustedCert);
    
    SecTrustSetAnchorCertificates(trust, newAnchorArray);
    
#ifndef PRE_10_6_COMPAT
    /* In iOS or OS X v10.6 and later, reenable the
     built-in anchors after adding your own.
     */
    SecTrustSetAnchorCertificatesOnly(trust, false);
#endif
    
    return trust;
}

- (SecCertificateRef)createCertificateFromFile:(NSString *)filename fileType:(NSString *)type{
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *dataFile = [bundle pathForResource:filename ofType:type];
    return SecCertificateCreateWithData(kCFAllocatorDefault, (CFDataRef)[NSData dataWithContentsOfFile:dataFile]);
    
}

@end
