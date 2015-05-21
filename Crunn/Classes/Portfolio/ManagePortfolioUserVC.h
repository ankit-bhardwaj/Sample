//
//  ManagePortfolioUserVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/9/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Portfolio.h"

typedef enum
{
    ManagePortfolioUserTypePortfolio,
    ManagePortfolioUserTypeProject
}ManagePortfolioUserType;

@interface ManagePortfolioUserVC : UIViewController

@property(nonatomic,strong)id target;
@property(nonatomic,assign)SEL action;
@property(nonatomic,retain)Portfolio* portfolio;
@property(nonatomic,retain)Project* project;
@property(nonatomic,assign) ManagePortfolioUserType portfolioUserType;
@end
