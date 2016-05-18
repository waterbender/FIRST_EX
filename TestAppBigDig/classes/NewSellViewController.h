//
//  NewSellViewController.h
//  TestAppBigDig
//
//  Created by  ZHEKA on 17.05.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "Product+CoreDataProperties.h"
#import "MainViewController.h"

@protocol ReloadViewDelegate <NSObject>

-(void) reloadFirstPageView;

@end

@interface NewSellViewController : UIViewController

@property (strong, nonatomic) MainViewController* delegate;
@property (strong, nonatomic) Product* product;

@end
