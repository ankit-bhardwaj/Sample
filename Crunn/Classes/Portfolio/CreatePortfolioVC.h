//
//  CreatePortfolioVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Portfolio.h"

typedef enum
{
    CreateTypePortfolio,
    CreateTypeProject,
    EditTypePortfolio,
    EditTypeProject
}CreatePortfolioType;

@interface CreatePortfolioVC : UIViewController
@property(nonatomic,assign) CreatePortfolioType portfolioType;
@property(nonatomic,retain) Portfolio* selectedPortfolio;
@property(nonatomic,retain) Project* selectedProject;
@end
