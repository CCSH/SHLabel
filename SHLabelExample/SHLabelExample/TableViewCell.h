//
//  TableViewCell.h
//  SHLabelExample
//
//  Created by CSH on 2017/11/9.
//  Copyright © 2017年 CSH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHLabel.h"

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet SHLabel *lab;

@end
