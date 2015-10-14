/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */
#import <Photos/Photos.h>
#import "CTRecentImages.h"

@implementation CTRecentImages

- (instancetype)init {
    if (!self.imagesArray){
        self.imagesArray = [[NSMutableArray alloc] init];
    }
    return [super init];
}

- (void)fetchRecentPhotosWithImageOptions:(NSDictionary *)imageOptions completion:(void (^)(NSArray *images))completion {
    self.maximumImagesCount = [[imageOptions objectForKey:@"maximumImagesCount"] integerValue];
    self.width = [[imageOptions objectForKey:@"width"] integerValue];
    self.height = [[imageOptions objectForKey:@"height"] integerValue];
    self.quality = [[imageOptions objectForKey:@"quality"] floatValue];
    [self checkGalleryPermissions:^(BOOL granted) {
        if(granted) {
            [self fetchRecentPhotosWithIndexCount:0 completion:completion];

        }
    }];
}
- (void)fetchRecentPhotosWithIndexCount:(int)indexCount completion:(void (^)(NSArray *images))completion {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.networkAccessAllowed = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    fetchOptions.fetchLimit = self.maximumImagesCount;
    
    PHFetchResult *photos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    
    if (photos) {
        [[PHImageManager defaultManager] requestImageForAsset:[photos objectAtIndex:photos.count -1 -indexCount] targetSize:CGSizeMake(self.width, self.height) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            UIImage *scaledImage = [self imageByScalingNotCroppingForSize:result toSize:CGSizeMake(self.width, self.height)];
            NSString *encodedImage = [self encodeToBase64String:scaledImage];
            [self.imagesArray addObject:encodedImage];
            
            if (indexCount + 1 < photos.count && self.imagesArray.count < 10) {
                [self fetchRecentPhotosWithIndexCount:indexCount +1 completion:completion];
            } else {
                completion([self.imagesArray copy]);
            }
        }];
    }
}
- (NSString *)encodeToBase64String:(UIImage *)image {
    return[UIImageJPEGRepresentation(image, self.quality) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
- (UIImage*)imageByScalingNotCroppingForSize:(UIImage*)anImage toSize:(CGSize)frameSize
{
    UIImage* sourceImage = anImage;
    UIImage* newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = frameSize.width;
    CGFloat targetHeight = frameSize.height;
    CGFloat scaleFactor = 0.0;
    CGSize scaledSize = frameSize;
    
    if (CGSizeEqualToSize(imageSize, frameSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        // opposite comparison to imageByScalingAndCroppingForSize in order to contain the image within the given bounds
        if (widthFactor == 0.0) {
            scaleFactor = heightFactor;
        } else if (heightFactor == 0.0) {
            scaleFactor = widthFactor;
        } else if (widthFactor > heightFactor) {
            scaleFactor = heightFactor; // scale to fit height
        } else {
            scaleFactor = widthFactor; // scale to fit width
        }
        scaledSize = CGSizeMake(width * scaleFactor, height * scaleFactor);
    }
    
    UIGraphicsBeginImageContext(scaledSize); // this will resize
    
    [sourceImage drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    
    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)checkGalleryPermissions:(void (^)(BOOL granted))block
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status)
    {
        case PHAuthorizationStatusAuthorized:
            block(YES);
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus)
             {
                 if (authorizationStatus == PHAuthorizationStatusAuthorized)
                 {
                     block(YES);
                 }
                 else
                 {
                     block(NO);
                 }
             }];
            break;
        }
        default:
            block(NO);
            break;
    }
}

@end
