/*******************************************************************************
 * Copyright (c) 2015 Chengxiong Ruan
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/

#import "NavLog.h"

@implementation NavLog

static int stderrSave = 0;

+ (void)startLog {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"devmode_preference"]) {
        return;
    }
    if (stderrSave != 0) {
        return;
    }
    NSDictionary* env = [[NSProcessInfo processInfo] environment];
    if ([[env valueForKey:@"log2file"] isEqual:@"false"]) {
        NSLog(@"Start log to console");
        stderrSave = -1;
        return;
    }
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss'.log'"];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    NSString *fileName = [formatter stringFromDate:[NSDate date]];
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [dir stringByAppendingPathComponent:fileName];
    NSLog(@"Start log to %@", path);
    
    stderrSave = dup(STDERR_FILENO);
    freopen([path UTF8String],"a+",stderr);
}

+(void)stopLog {
    if(stderrSave == 0) {
        return;
    }
    if (stderrSave > 0) {
        fflush(stderr);
        dup2(stderrSave, STDERR_FILENO);
        close(stderrSave);
    }
    stderrSave = 0;
    NSLog(@"Stop log");
}

+(BOOL)isLogging {
    return stderrSave != 0;
}

+(void)logBeacons:(NSArray *)beacons{
    if(stderrSave == 0) {
        return;
    }
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendFormat:@"Beacon,%ld", (unsigned long)[beacons count]];
    for(int i = 0; i < [beacons count]; i++) {
        CLBeacon *b = (CLBeacon*)[beacons objectAtIndex:i];
        [str appendFormat:@",%@,%@,%ld",b.major, b.minor, (long)b.rssi];
    }
    NSLog(@"%@", str);
}

+(void)logMotion:(CMDeviceMotion *)data withFrame:(CMAttitudeReferenceFrame)frame {
    if(stderrSave == 0) {
        return;
    }
    NSLog(@"Motion,%f,%f,%f",data.attitude.pitch,data.attitude.roll,data.attitude.yaw);
}

+(void)logAcc:(CMAccelerometerData *) data {
    if(stderrSave == 0) {
        return;
    }
    NSLog(@"Acc,%f,%f,%f",data.acceleration.x,data.acceleration.y,data.acceleration.z);
}

+(void)logMotion:(NSDictionary *)data {
    if(stderrSave == 0) {
        return;
    }
    
    NSNumber *pitch = [data objectForKey:@"pitch"];
    NSNumber *roll = [data objectForKey:@"roll"];
    NSNumber *yaw = [data objectForKey:@"yaw"];
    
    NSLog(@"Motion,%f,%f,%f", [pitch doubleValue], [roll doubleValue], [yaw doubleValue]);
}

+(void)logArray:(NSArray *)data withType:(NSString *)type {
    if(stderrSave == 0) {
        return;
    }
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:type];
    for(NSObject *obj in data) {
        [str appendFormat:@",%@", obj];
    }
    NSLog(@"%@", str);
}

@end
