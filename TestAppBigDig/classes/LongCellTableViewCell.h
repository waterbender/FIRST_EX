//
//  LongCellTableViewCell.h
//  TestAppBigDig
//
//  Created by  ZHEKA on 18.05.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LongCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageMainView;
@property (weak, nonatomic) IBOutlet UITextView *desctiptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIPageControl *photoControl;
@property (strong, nonatomic) NSMutableArray *allPhotosArray;

@end
