//
//  DetailedViewController.h
//  Sound-Church
//
//  Created by John Ahrens on 7/23/11.
//  Copyright © 2011 John Ahrens, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailedViewController : UIViewController {
    IBOutlet UIImageView *image;
    IBOutlet UISlider *playbackProgress;
}

@property (nonatomic, retain)UIImageView *image;
@property (nonatomic, retain)UISlider *playbackProgress;

- (IBAction)setPlaybackPosition: (double)position;

@end
