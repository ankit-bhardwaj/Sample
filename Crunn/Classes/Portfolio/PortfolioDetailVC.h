//
//  PortfolioDetailVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 4/7/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Portfolio.h"

typedef enum
{
    DetailTypePortfolio,
    DetailTypeProject
}DetailPortfolioType;

@interface PortfolioDetailVC : UIViewController
@property(nonatomic,assign) DetailPortfolioType portfolioType;
@property(nonatomic,retain) Portfolio* selectedPortfolio;
@property(nonatomic,retain) Project* selectedProject;
@property (nonatomic, retain)IBOutlet UITableView* tblView;

@end
