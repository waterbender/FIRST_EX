//
//  NewSellViewController.m
//  TestAppBigDig
//
//  Created by  ZHEKA on 17.05.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//

#import "NewSellViewController.h"
#import "ImageCell.h"
#import "DataManager.h"
#import "KTCenterFlowLayout.h"

@interface NewSellViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *itemTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UIView *priceFullView;

@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (strong, nonatomic) NSString *firstString;
@property (assign, nonatomic) CGRect previousRect;

@end

@implementation NewSellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imagesArray= [[NSMutableArray alloc] init];
    
    if (self.product) {
        self.itemTextField.text = _product.name;
        self.descriptionTextField.text = _product.info;
        self.priceTextField.text = [_product.price stringValue];
        
        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:_product.images];
        [self.imagesArray addObjectsFromArray:array];
        [self.collectionView reloadData];
    }
    
    KTCenterFlowLayout *layout = [KTCenterFlowLayout new];
    layout.minimumInteritemSpacing = 10.f;
    layout.minimumLineSpacing = 10.f;

    [self.collectionView setCollectionViewLayout:layout];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)backToRootVC:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *indet = @"ExampleOfImageCell";
    ImageCell *cell = (ImageCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:indet forIndexPath:indexPath];
    
    if (indexPath.item == 0) {
        UIImage *image = [UIImage imageNamed:@"photo"];
        cell.mainImageView.image = nil;
        [cell.mainImageView setImage:image];
        return cell;
    } else {

        UIImage *image = [self.imagesArray objectAtIndex:indexPath.item - 1];
        cell.mainImageView.image = nil;
        [cell.mainImageView setImage:image];
        
        return cell;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(92.f, 92.f);
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.itemTextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
    [self.priceTextField resignFirstResponder];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == 0) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else {
        [self.imagesArray removeObjectAtIndex:indexPath.item-1];
        [self.collectionView reloadData];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    // Dismiss the image selection, hide the picker and
        
    CGFloat compression = 0.001;
    CGFloat maxCompression = 0.1;
    int maxFileSize = 10;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    [self.imagesArray addObject:[UIImage imageWithData:imageData]];
    //show the image view with the picked image
    [self.collectionView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)addToDataBase:(UIButton *)sender {
    
    DataManager *dataManager = [DataManager sharedManager];
    
    if ([self.imagesArray count] == 0) {
        [self.imagesArray addObject:[UIImage imageNamed:@"photo"]];
    }
    
    self.delegate.fetchedResultsController = nil;
    
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:self.imagesArray];
    
    if (self.product) {
        
        self.product.images = arrayData;
        self.product.name = self.itemTextField.text;
        self.product.price = [NSNumber numberWithDouble:self.priceTextField.text.doubleValue];
        self.product.info = self.descriptionTextField.text;
        
        [dataManager saveContext];
        
    } else  {
        
        NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
        [infoDict setObject:self.itemTextField.text forKey:@"name"];
        [infoDict setObject:arrayData forKey:@"images"];
        
        [infoDict setObject:self.descriptionTextField.text forKey:@"info"];
        [infoDict setObject:[NSNumber numberWithDouble:self.priceTextField.text.doubleValue] forKey:@"price"];
        
        [dataManager setNewDictProductIntoDB:infoDict];
        [dataManager saveContext];
        
    }
    
    [self.delegate performSelector:@selector(reloadFirstPageView) withObject:nil];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.firstString = textField.text;
    textField.text = @"";
    
    if ([textField isEqual:self.priceTextField]) {
        [UIView animateWithDuration:2 animations:^{
            CGRect frame = self.priceFullView.frame;
            self.previousRect = frame;
            CGRect newFrame = CGRectMake(CGRectGetMinX(frame), self.itemTextField.frame.origin.y, CGRectGetWidth(frame), CGRectGetHeight(frame));
            self.priceFullView.frame = newFrame;
            
            self.descriptionTextField.backgroundColor = [UIColor grayColor];
        }];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text length] == 0) {
        textField.text = self.firstString;
    }
    
    if ([textField isEqual:self.priceTextField]) {
        [UIView animateWithDuration:2 animations:^{
            CGRect frame = self.priceFullView.frame;
            CGRect newFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(self.previousRect), CGRectGetWidth(frame), CGRectGetHeight(frame));
            self.priceFullView.frame = newFrame;
            
            self.descriptionTextField.backgroundColor = [UIColor whiteColor];
        }];
    }
}

#pragma mark -UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.firstString = textView.text;
    textView.text = @"";
    
    [UIView animateWithDuration:2 animations:^{
        CGRect frame = textView.frame;
        self.previousRect = frame;
        CGRect newFrame = CGRectMake(CGRectGetMinX(frame), self.itemTextField.frame.origin.y, CGRectGetWidth(frame), CGRectGetHeight(frame));
        textView.frame = newFrame;
    }];

}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text length] == 0) {
        textView.text = self.firstString;
    }
    
    [UIView animateWithDuration:2 animations:^{
        CGRect frame = textView.frame;
        CGRect newFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(self.previousRect), CGRectGetWidth(frame), CGRectGetHeight(frame));
        textView.frame = newFrame;
    }];

}

@end
