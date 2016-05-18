//
//  LongCellTableViewCell.m
//  TestAppBigDig
//
//  Created by  ZHEKA on 18.05.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//

#import "LongCellTableViewCell.h"

@interface LongCellTableViewCell()



@end

@implementation LongCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)newPage:(UIPageControl*)sender {
    
    self.imageMainView.image = nil;
    [self.imageMainView setImage: [self.allPhotosArray objectAtIndex:sender.currentPage]];
}

@end
