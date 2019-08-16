//
//  TableViewController.m
//  SHLabelExample
//
//  Created by CSH on 2017/11/9.
//  Copyright © 2017年 CSH. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"

@interface TableViewController ()

@property (nonatomic, copy) NSArray <SHLabelModel *>*modelArr;

@end

@implementation TableViewController

static NSString *const content = @"阿松的海景房a婚的高发杉本繁郎火结婚的高发杉本繁郎火213472013sadf我被批好闻哦内存三次吧类型国产赛跑堵车比USA的撒开了短发后撒电话发菩我和谁都烦死了都快分";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *modelArr  = [[NSMutableArray alloc]init];
    
    NSInteger loc = 0;
    NSInteger len = 1;
    
    for (int i = 0; i < 20; i++) {
        
        SHLabelModel *model = [[SHLabelModel alloc]init];
        
        model.parameter = [NSString stringWithFormat:@"%d",i];
        model.range = NSMakeRange(loc, len);
        
        loc += len + arc4random()%5;

        len = 1 + arc4random()%4;

        if ((loc + len) > content.length) {
            break;
        }
        
        [modelArr addObject:model];
    }
    self.modelArr = modelArr;
    
    self.tableView.rowHeight = 100;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];

    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:nil options:nil] lastObject];
    }
    
    cell.lab.tag = indexPath.row;
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    
    paragraphStyle.lineSpacing = 15;
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:content       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                     NSParagraphStyleAttributeName: paragraphStyle}];


     NSArray *colorArr = @[[UIColor darkGrayColor],[UIColor lightGrayColor],[UIColor grayColor],[UIColor redColor],[UIColor orangeColor],[UIColor lightGrayColor],[UIColor redColor],[UIColor orangeColor],[UIColor lightGrayColor],[UIColor greenColor],[UIColor blueColor],[UIColor cyanColor],[UIColor yellowColor],[UIColor magentaColor],[UIColor orangeColor],[UIColor purpleColor],[UIColor brownColor]];
    for (SHLabelModel *obj in self.modelArr) {
        [att addAttributes:@{NSForegroundColorAttributeName: colorArr[arc4random()%colorArr.count]} range:obj.range];
    }
    
    cell.lab.attributedText = att;
    cell.lab.modelArr = self.modelArr;
    cell.lab.isEffect = YES;
    cell.lab.block = ^(SHLabel *lab, SHLabelModel *model) {
        if (model) {
            //内容回调
            UIAlertView *ale = [[UIAlertView alloc]initWithTitle:@"点击响应" message:[NSString stringWithFormat:@"第%ld个\n参数:%@",(long)lab.tag,model.parameter] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [ale show];
        }else{
            NSLog(@"第%ld个 === 点击了空白位置",(long)lab.tag);
        }
    };
    
    return cell;
}

@end
