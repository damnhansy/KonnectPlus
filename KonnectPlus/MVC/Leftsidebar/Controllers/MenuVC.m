//
//  MenuVC.m
//  KonnectPlus
//
//  Created by One Platinum on 12/26/14.
//  Copyright (c) 2014 One Platinum. All rights reserved.
//

#import "MenuVC.h"

@interface MenuVC ()

@end

@implementation MenuVC
@synthesize HUD,testArray,PortofolioVCArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self DataDownload];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    topItems=[[NSMutableArray alloc]init];
    subItems=[[NSMutableArray alloc]init];
    subItems=[[NSMutableArray alloc]init];
    self.PortofolioVCArray=[[NSMutableArray alloc] init];
    self.testArray=[[NSMutableArray alloc] init];
    currentExpandedIndex = -1;
    self.tableView.separatorColor = [UIColor clearColor];

   // [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"ico_nav.png"] forBarMetrics:UIBarMetricsDefault];
    
    //[self.revealSideViewController resetOption:PPRevealSideOptionsiOS7StatusBarFading];
    //[self.revealSideViewController setOption:PPRevealSideOptionsNone];  //  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];


    // Do any additional setup after loading the view.
}
-(void)DataDownload{
    [self addActivity];
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    
    // NSDictionary *postParams;
    NSString *token=@"ANGxryY2MgDEruiOfIFMGwKdaQlDAQxnXQrRku";
    NSString *url=[NSString stringWithFormat:@"http://api_konnectplus.tv:H23RNVSTYPP46WFY@konnectplus.tv/api/device/category?user_id=%@&token=%@",userID,token];
    //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"api_konnectplus.tv" password:@"H23RNVSTYPP46WFY" persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        if([[responseObject valueForKey:@"status"] isEqualToString:@"false"]){
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error!" message:[responseObject valueForKey:@"error"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert show];
        }
        else{
            
            
            NSArray *catArray=[responseObject valueForKey:@"category"] ;
            NSMutableDictionary * DealsVCDictionary = [[NSMutableDictionary alloc] init];
            NSMutableDictionary * subcatDealsVCDictionary = [[NSMutableDictionary alloc] init];
            NSMutableArray * dealsDataArray = [[NSMutableArray alloc] init];
            NSMutableArray * subCatDataArray = [[NSMutableArray alloc] init];
            
            
            for(int i = 0; i < [catArray count]; i++)
            {
                sidebarDataModel *dealsDataModel=[[sidebarDataModel alloc]init];
                
                DealsVCDictionary = [catArray objectAtIndex:i];
                dealsDataModel.cat_id=[ DealsVCDictionary valueForKey:@"id"];
                dealsDataModel.name=[ DealsVCDictionary valueForKey:@"title"];
                [topItems addObject:[ DealsVCDictionary valueForKey:@"title"]];
                NSMutableArray    *subItemsArray=[NSMutableArray new];
                testArray=[NSMutableArray new];
                [testArray addObject:dealsDataModel];
                
                //
                NSArray *subcatArray= [DealsVCDictionary valueForKey:@"subcategory"];
                for (int j=0; j<[subcatArray count]; j++) {
                    subcatDealsVCDictionary = [subcatArray objectAtIndex:j];
                    sidebarDataModel *dealsDataModel1=[[sidebarDataModel alloc]init];
                    [subItemsArray addObject:[ subcatDealsVCDictionary valueForKey:@"title"]];

                    dealsDataModel1.subcat_id=[ subcatDealsVCDictionary valueForKey:@"id"];
                    dealsDataModel1.subCat_name=[ subcatDealsVCDictionary valueForKey:@"title"];
                    [self.PortofolioVCArray addObject:dealsDataModel1];

                    
                }
                
                // [dealsDataArray addObject:dealsDataModel];
                //[subCatDataArray addObject:dealsDataModel];
                [subItems addObject:subItemsArray];
                
                
                
            }
            
            //  [topItems addObjectsFromArray:dealsDataArray];
            //  [subItems addObjectsFromArray:subCatDataArray];
            
            
            
            
            
            
            
            
            
            [self.tableView reloadData];
            [self.tableView reloadInputViews];
            [self removeActivity];
            
            
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
        [self removeActivity];
        
    }];
    
    [manager.operationQueue addOperation:operation];
    
    
}
#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [topItems count] + ((currentExpandedIndex > -1) ? [[subItems objectAtIndex:currentExpandedIndex] count] : 0);
    //NSLog(@"%d",[topItems count]);
    //return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ParentCellIdentifier = @"ParentCell";
    static NSString *ChildCellIdentifier = @"ChildCell";
    
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [[subItems objectAtIndex:currentExpandedIndex] count];
    
    sidebarCell *cell;
    
    if (isChild) {
        cell = [tableView dequeueReusableCellWithIdentifier:ChildCellIdentifier];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:ParentCellIdentifier];
    }
    
    
    if (cell == nil) {
        cell = [[sidebarCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ParentCellIdentifier ];
    }
    
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:125.0f/255 green:189.0f/255 blue:255.0f/255 alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    if (isChild) {
        
        if(IS_IPHONE){
            [ cell.detailTextLabel setFont:[UIFont systemFontOfSize:17]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[[subItems objectAtIndex:currentExpandedIndex] objectAtIndex:indexPath.row - currentExpandedIndex - 1] ];
             cell.backgroundColor=[UIColor colorWithRed:199.0f/255 green:199.0f/255 blue:199.0f/255 alpha:1];
        }
        else if(IS_IPAD){
            [ cell.detailTextLabel setFont:[UIFont systemFontOfSize:17]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[[subItems objectAtIndex:currentExpandedIndex] objectAtIndex:indexPath.row - currentExpandedIndex - 1] ];
            cell.backgroundColor=[UIColor colorWithRed:199.0f/255 green:199.0f/255 blue:199.0f/255 alpha:1];

    }
    }
    else {
        int topIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex)
        ? indexPath.row - [[subItems objectAtIndex:currentExpandedIndex] count]
        : indexPath.row;
        
        
        if(IS_IPHONE){
        cell.backgroundColor=[UIColor colorWithRed:199.0f/255 green:199.0f/255 blue:199.0f/255 alpha:1];
        cell.textLabel.textColor=[UIColor blackColor];
        cell.MyLabel.text=[topItems objectAtIndex:topIndex];
        }
        else if(IS_IPAD){
            cell.backgroundColor=[UIColor colorWithRed:199.0f/255 green:199.0f/255 blue:199.0f/255 alpha:1];
            cell.textLabel.textColor=[UIColor blackColor];
            cell.MyLabel.text=[topItems objectAtIndex:topIndex];
        }
    }
    tableView.tableFooterView = [[UIView alloc] init];
   // cell.selectionStyle = UITableViewCellSelectionStyleNone;
   // cell.selectedBackgroundView=[UIColor colorWithRed:125.0f/255 green:189.0f/255 blue:255.0f/255 alpha:1];
 
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SWRevealViewController *revealController = self.revealViewController;

    
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [[subItems objectAtIndex:currentExpandedIndex] count];
    int prevExpandedIndex = currentExpandedIndex;
    
    if (isChild) {
        NSLog(@"A child was tapped, do what you will with it");
        sidebarDataModel *model=[PortofolioVCArray objectAtIndex:indexPath.row-1];
        MainVC *main=[[MainVC alloc]init];
        UIStoryboard *sb;
        
        if(IS_IPAD){
            sb = [UIStoryboard storyboardWithName:@"ipad" bundle:nil];
            
        }
        else if(IS_IPHONE){
            sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        }
        
        main = [sb instantiateViewControllerWithIdentifier:@"MAINID"];
        main.subCatID=[model subcat_id];
        main.isFromSideMenu=YES;
              UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:main];
        
        [revealController pushFrontViewController:n animated:YES];


        return;
    }
    else
    {
        
    }
    [self.tableView beginUpdates];
    
    if (currentExpandedIndex == indexPath.row) {
        [self collapseSubItemsAtIndex:currentExpandedIndex];
        currentExpandedIndex = -1;
    }
    else {
        
        BOOL shouldCollapse = currentExpandedIndex > -1;
        
        if (shouldCollapse) {
            [self collapseSubItemsAtIndex:currentExpandedIndex];
        }
        
        currentExpandedIndex = (shouldCollapse && indexPath.row > currentExpandedIndex) ? indexPath.row - [[subItems objectAtIndex:currentExpandedIndex] count] : indexPath.row;
        
        [self expandItemAtIndex:currentExpandedIndex];
    }
    
    [self.tableView endUpdates];
    
    
    if (!isChild && currentExpandedIndex > 0 && prevExpandedIndex >= 0) {
        if([[subItems objectAtIndex:currentExpandedIndex] count] > 0)
        {
        }
        else
        {
            
            int newIndexPath;
            if(indexPath.row > prevExpandedIndex)
                newIndexPath = indexPath.row - [[subItems objectAtIndex:prevExpandedIndex] count];
            else
                newIndexPath = indexPath.row;
            
            sidebarDataModel *model=[testArray objectAtIndex:newIndexPath];
            MainVC *main=[[MainVC alloc]init];
            UIStoryboard *sb;
            
            if(IS_IPAD){
                sb = [UIStoryboard storyboardWithName:@"ipad" bundle:nil];
                
            }
            else if(IS_IPHONE){
                sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            }
            
            main = [sb instantiateViewControllerWithIdentifier:@"MAINID"];
            //detail.paymentStatus=[model paymentstatusl];
            main.subCatID=[model subcat_id];
            //detail.title=[model title];
            // detail.delegate=self;
            UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:main];

            main.isFromSideMenu=YES;
          //  [self.delegate pushView:main];
          //  [self.navigationController pushViewController:main animated:YES];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
    
    
    
}

- (void)expandItemAtIndex:(int)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
   // NSMutableArray *currentSubItems=[[NSMutableArray alloc]init];
  NSArray  *currentSubItems = [subItems objectAtIndex:index];
    int insertPos = index + 1;
    for (int i = 0; i < [currentSubItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)collapseSubItemsAtIndex:(int)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i = index + 1; i <= index + [[subItems objectAtIndex:index] count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)addActivity{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.delegate = self;
    //  HUD.color=[UIColor redColor];
    HUD.labelText = @"Loding...";
    self.view.userInteractionEnabled=FALSE;
    //HUD.c
    [HUD show:YES];
}
-(void)removeActivity{
    
    self.view.userInteractionEnabled=TRUE;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

@end
