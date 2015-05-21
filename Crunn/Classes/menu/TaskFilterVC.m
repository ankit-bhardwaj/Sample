//
//  TaskFilterVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 4/18/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import "TaskFilterVC.h"
#import "CLTokenInputView.h"
#import "TaskDocument.h"

@interface TaskFilterVC ()
{
    IBOutlet UITableView* tableView;
    
    IBOutlet UITableView* filteredTableView;
    BOOL _filterOpened;
    
    IBOutlet UIButton* includeCompBtn;
    
    CLTokenInputView* _currentInputView;
    
    NSString* _searchKeyword;
    NSString* _wordKeyword;
}

@property (strong, nonatomic) NSArray *filteredAssginee;
@property (strong, nonatomic) NSMutableArray *selectedAssginee;

@property (strong, nonatomic) NSArray *filteredCreators;
@property (strong, nonatomic) NSMutableArray *selectedCreators;


@property (strong, nonatomic) NSArray *filteredProjects;
@property (strong, nonatomic) NSMutableArray *selectedProjects;

@property (strong, nonatomic) NSArray *filteredPortfolios;
@property (strong, nonatomic) NSArray *portfolios;
@property (strong, nonatomic) NSMutableArray *selectedPortfolios;

- (IBAction)toogleIncludeDoneTasks:(UIButton*)btn;

@end

@implementation TaskFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[TaskDocument sharedInstance] getProjectList];
    [[TaskDocument sharedInstance] getAssigneeListForSearch:nil];
    
    _selectedAssginee = [NSMutableArray new];
    _selectedCreators = [NSMutableArray new];
    _selectedPortfolios = [NSMutableArray new];
    _selectedProjects = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UITextField*)createTextField
{
    UITextField* txt = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, tableView.bounds.size.width-40, 34)];
    txt.background = [[UIImage imageNamed:@"blue_placeholder.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 34)];
    [v setBackgroundColor:[UIColor clearColor]];
    txt.leftView = v;
    txt.leftViewMode = UITextFieldViewModeAlways;
    txt.delegate = self;
    return txt;
}

- (CLTokenInputView*)createCLTokenInputView
{
    CLTokenInputView* txt = [[CLTokenInputView alloc] initWithFrame:CGRectMake(20, 10, tableView.bounds.size.width-40, 34)];
    txt.backgroundColor = [UIColor whiteColor];
    txt.delegate = self;
    return txt;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    filteredTableView.hidden = YES;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag - 1000) {
        case 0:
            _searchKeyword =  textField.text;
            break;
        case 1:
            _wordKeyword =  textField.text;
            break;
            
        default:
            break;
    }
}
- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(NSString *)text{
    if ([text isEqualToString:@""]){
        switch (view.tag - 1000) {
            case 2:
                self.filteredAssginee = nil;
                break;
            case 3:
                self.filteredCreators = nil;
                break;
            case 4:
                self.filteredPortfolios = nil;
                break;
            case 5:
                self.filteredProjects = nil;
                break;
                
            default:
                break;
        }
        
        filteredTableView.hidden = YES;
    } else {
        _currentInputView = view;
        NSInteger index = view.tag - 1000;
        CGRect r = [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        CGRect rect = filteredTableView.frame;
        rect.origin.y  = r.origin.y + _currentInputView.frame.size.height - tableView.contentOffset.y + 20;
        [filteredTableView setFrame:rect];
        switch ( index){
            case 2:
            {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"FormattedName CONTAINS[c] %@",text];
                NSMutableArray* arr = [[TaskDocument sharedInstance] assignees];
                if(arr.count==0)
                    [[TaskDocument sharedInstance] getAssigneeListForSearch:nil];
                self.filteredAssginee = [arr filteredArrayUsingPredicate:predicate];
                break;
            }
            case 3:
            {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"FormattedName CONTAINS[c] %@",text];
                NSMutableArray* arr = [[TaskDocument sharedInstance] assignees];
                if(arr.count==0)
                    [[TaskDocument sharedInstance] getAssigneeListForSearch:nil];
                self.filteredCreators = [arr filteredArrayUsingPredicate:predicate];
                break;
            }
            case 4:
            {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"PortfolioName CONTAINS[c] %@",text];
                NSMutableArray* arr = [[TaskDocument sharedInstance] portfolios];
                if(arr.count==0)
                    [[TaskDocument sharedInstance] getProjectList];
                self.filteredPortfolios = [arr filteredArrayUsingPredicate:predicate];
                break;
            }
            case 5:
            {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ProjectName CONTAINS[c] %@",text];
                NSMutableArray* arr = [[TaskDocument sharedInstance] projects];
                if(arr.count==0)
                    [[TaskDocument sharedInstance] getProjectList];
                self.filteredProjects = [arr filteredArrayUsingPredicate:predicate];
                break;
            }
                
            default:
                break;
        }
        filteredTableView.hidden = NO;
    }
    [filteredTableView reloadData];
}

- (void)tokenInputView:(CLTokenInputView *)view didAddToken:(CLToken *)token
{
    
    switch (view.tag - 1000) {
        case 2:
        {
            User *user = (User*)token.context;
            [self.selectedAssginee addObject:user];
            break;
        }
        case 3:
        {
            User *user = (User*)token.context;
            [self.selectedCreators addObject:user];
            break;
        }
        case 4:
        {
            Portfolio *portfolio = (Portfolio*)token.context;
            [self.selectedPortfolios addObject:portfolio];
            break;
        }
        case 5:
        {
            Project *project = (Project*)token.context;
            [self.selectedProjects addObject:project];
            break;
        }
            
        default:
            break;
    }
    
}

- (void)tokenInputView:(CLTokenInputView *)view didRemoveToken:(CLToken *)token
{
    switch (view.tag - 1000) {
        case 2:
        {
            User *user = (User*)token.context;
            [self.selectedAssginee removeObject:user];
            break;
        }
        case 3:
        {
            User *user = (User*)token.context;
            [self.selectedCreators removeObject:user];
            break;
        }
        case 4:
        {
            Portfolio *portfolio = (Portfolio*)token.context;
            [self.selectedPortfolios removeObject:portfolio];
            break;
        }
        case 5:
        {
            Project *project = (Project*)token.context;
            [self.selectedProjects removeObject:project];
            break;
        }
            
        default:
            break;
    }
}
- (CLToken *)tokenInputView:(CLTokenInputView *)view tokenForText:(NSString *)text
{
    switch (view.tag - 1000) {
        case 2:
        {
            if (self.selectedAssginee.count > 0) {
                User *matching = self.selectedAssginee[0];
                CLToken *match = [[CLToken alloc] initWithDisplayText:matching.FormattedName context:matching];
                return match;
            }
        }
        case 3:
        {
            if (self.selectedCreators.count > 0) {
                User *matching = self.selectedCreators[0];
                CLToken *match = [[CLToken alloc] initWithDisplayText:matching.FormattedName context:matching];
                return match;
            }
        }
        case 4:
        {
            if (self.selectedPortfolios.count > 0) {
                Portfolio *matching = self.selectedPortfolios[0];
                CLToken *match = [[CLToken alloc] initWithDisplayText:matching.PortfolioName context:matching];
                return match;
            }
        }
        case 5:
        {
            if (self.selectedProjects.count > 0) {
                Project *matching = self.selectedProjects[0];
                CLToken *match = [[CLToken alloc] initWithDisplayText:matching.ProjectName context:matching];
                return match;
            }
        }
            
        default:
            break;
    }
    
    // TODO: Perhaps if the text is a valid phone number, or email address, create a token
    // to "accept" it.
    return nil;
}
- (void)tokenInputView:(CLTokenInputView *)view didChangeHeightTo:(CGFloat)height
{
    if(view.tag != 0)
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if(tv == tableView)
    {
        if(!_filterOpened)
            return 1;
        return 7;
    }
    else
    {
        switch (_currentInputView.tag - 1000) {
            case 2:
            {
                return self.filteredAssginee.count;
            }
            case 3:
            {
                return self.filteredCreators.count;
            }
            case 4:
            {
                return self.filteredPortfolios.count;
            }
            case 5:
            {
                return self.filteredProjects.count;
            }
                
            default:
                break;
        }
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tv == tableView)
    {
        switch (indexPath.row) {
            case 2:
            {
                NSMutableString* string = [NSMutableString string];
                for(User* matching in self.selectedAssginee) {
                    [string appendString:matching.FormattedName];
                    [string appendString:@", "];
                }
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSParagraphStyleAttributeName:paragraphStyle};
                CGRect size = [string boundingRectWithSize:CGSizeMake(tableView.bounds.size.width-100, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
                return MAX(60.0, size.size.height+30);
            }
            case 3:
            {
                NSMutableString* string = [NSMutableString string];
                for(User* matching in self.selectedCreators) {
                    [string appendString:matching.FormattedName];
                    [string appendString:@", "];
                }
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSParagraphStyleAttributeName:paragraphStyle};
                CGRect size = [string boundingRectWithSize:CGSizeMake(tableView.bounds.size.width-100, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
                return MAX(60.0, size.size.height+30);
            }
            case 4:
            {
                NSMutableString* string = [NSMutableString string];
                for(Portfolio* matching in self.selectedPortfolios) {
                    [string appendString:matching.PortfolioName];
                    [string appendString:@", "];
                }
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSParagraphStyleAttributeName:paragraphStyle};
                CGRect size = [string boundingRectWithSize:CGSizeMake(tableView.bounds.size.width-100, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
                return MAX(60.0, size.size.height+30);
            }
            case 5:
            {
                NSMutableString* string = [NSMutableString string];
                for(Project* matching in self.selectedProjects) {
                    [string appendString:matching.ProjectName];
                    [string appendString:@", "];
                }
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSParagraphStyleAttributeName:paragraphStyle};
                CGRect size = [string boundingRectWithSize:CGSizeMake(tableView.bounds.size.width-100, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
                return MAX(60.0, size.size.height+30);
            }
        }
        return 60.0;

    }
    else
    {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tv == tableView)
    {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = nil;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        switch (indexPath.row) {
            case 0:
            {
                UITextField* txt = [self createTextField];
                txt.tag = 1000+indexPath.row;
                txt.placeholder = @"Search for tasks...";
                [cell.contentView addSubview:txt];
                
                CGRect rect = txt.frame;
                rect.size.width -= 80;
                [txt setFrame:rect];
                
                UIButton* arrow = [UIButton buttonWithType:UIButtonTypeCustom];
                [arrow setFrame:CGRectMake(rect.size.width + 30, rect.origin.y, 40, 40)];
                [arrow setImage:[UIImage imageNamed:@"arrow_down.png"] forState:UIControlStateNormal];
                [arrow setImage:[UIImage imageNamed:@"arrow_up.png"] forState:UIControlStateSelected];
                [arrow addTarget:self action:@selector(toogleFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:arrow];
                
                UIButton* search = [UIButton buttonWithType:UIButtonTypeCustom];
                [search setFrame:CGRectMake(rect.size.width + 30 + 40, rect.origin.y, 40, 40)];
                [search setImage:[UIImage imageNamed:@"search_icon.png"] forState:UIControlStateNormal];
                [search addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:search];
                
                txt.text = _searchKeyword;
                if(!_filterOpened)
                    [txt becomeFirstResponder];
                break;

            }
            case 1:
            {
                UITextField* txt = [self createTextField];
                txt.text = _wordKeyword;
                txt.tag = 1000+indexPath.row;
                txt.placeholder = @"Contains the word...";
                [cell.contentView addSubview:txt];
                break;
            }
            case 2:
            {
                CLTokenInputView* txt = [self createCLTokenInputView];
                CGRect rect = txt.frame;
                NSMutableString* string = [NSMutableString string];
                for(User* matching in self.selectedAssginee) {
                    [string appendString:matching.FormattedName];
                    [string appendString:@", "];
                    CLToken *match = [[CLToken alloc] initWithDisplayText:matching.FormattedName context:matching];
                    [txt addToken:match];
                }
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSParagraphStyleAttributeName:paragraphStyle};
                CGRect size = [string boundingRectWithSize:CGSizeMake(rect.size.width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
                rect.size.height = MAX(34, size.size.height);
                [txt setFrame:rect];
                txt.tag = 1000+indexPath.row;
                txt.placeholderText = @"Assigned to...";
                [cell.contentView addSubview:txt];
                break;
            }
            case 3:
            {
                CLTokenInputView* txt = [self createCLTokenInputView];
                CGRect rect = txt.frame;
                NSMutableString* string = [NSMutableString string];
                for(User* matching in self.selectedCreators) {
                    [string appendString:matching.FormattedName];
                    [string appendString:@", "];
                    CLToken *match = [[CLToken alloc] initWithDisplayText:matching.FormattedName context:matching];
                    [txt addToken:match];
                }
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSParagraphStyleAttributeName:paragraphStyle};
                CGRect size = [string boundingRectWithSize:CGSizeMake(rect.size.width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
                rect.size.height = MAX(34, size.size.height);
                [txt setFrame:rect];
                txt.tag = 1000+indexPath.row;
                txt.placeholderText = @"Created by...";
                [cell.contentView addSubview:txt];
                break;
            }
            case 4:
            {
                CLTokenInputView* txt = [self createCLTokenInputView];
                CGRect rect = txt.frame;
                NSMutableString* string = [NSMutableString string];
                for(Portfolio* matching in self.selectedPortfolios) {
                    [string appendString:matching.PortfolioName];
                    [string appendString:@", "];
                    CLToken *match = [[CLToken alloc] initWithDisplayText:matching.PortfolioName context:matching];
                    [txt addToken:match];
                }
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSParagraphStyleAttributeName:paragraphStyle};
                CGRect size = [string boundingRectWithSize:CGSizeMake(rect.size.width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
                rect.size.height = MAX(34, size.size.height);
                [txt setFrame:rect];
                txt.tag = 1000+indexPath.row;
                txt.placeholderText = @"In portfolio...";
                [cell.contentView addSubview:txt];
                break;
            }
            case 5:
            {
                CLTokenInputView* txt = [self createCLTokenInputView];
                CGRect rect = txt.frame;
                NSMutableString* string = [NSMutableString string];
                for(Project* matching in self.selectedProjects) {
                    [string appendString:matching.ProjectName];
                    [string appendString:@", "];
                    CLToken *match = [[CLToken alloc] initWithDisplayText:matching.ProjectName context:matching];
                    [txt addToken:match];
                }
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSParagraphStyleAttributeName:paragraphStyle};
                CGRect size = [string boundingRectWithSize:CGSizeMake(rect.size.width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
                rect.size.height = MAX(34, size.size.height);
                [txt setFrame:rect];                txt.tag = 1000+indexPath.row;
                txt.placeholderText = @" In projects...";
                [cell.contentView addSubview:txt];
                break;
            }
            case 6:
            {
                [cell.contentView addSubview:includeCompBtn];
                includeCompBtn.center = cell.contentView.center;
                break;
            }
                
            default:
                break;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"CellOptions";
        
        UITableViewCell *cell = nil;
        if(!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        switch (_currentInputView.tag - 1000) {
            case 2:
            {
                User* user = [self.filteredAssginee objectAtIndex:indexPath.row];
                cell.textLabel.text = user.FormattedName;
                if ([self.selectedAssginee containsObject:user]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            }
            case 3:
            {
                User* user = [self.filteredCreators objectAtIndex:indexPath.row];
                cell.textLabel.text = user.FormattedName;
                if ([self.selectedCreators containsObject:user]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            }
            case 4:
            {
                Portfolio* user = [self.filteredPortfolios objectAtIndex:indexPath.row];
                cell.textLabel.text = user.PortfolioName;
                if ([self.selectedPortfolios containsObject:user]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            }
            case 5:
            {
                Project* user = [self.filteredProjects objectAtIndex:indexPath.row];
                cell.textLabel.text = user.ProjectName;
                if ([self.selectedProjects containsObject:user]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            }
                
            default:
                break;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tv == filteredTableView)
    {
        switch (_currentInputView.tag - 1000) {
            case 2:
            {
                User* user = [self.filteredAssginee objectAtIndex:indexPath.row];
                CLToken *token = [[CLToken alloc] initWithDisplayText:user.FormattedName context:user];
                [_currentInputView addToken:token];
                break;
            }
            case 3:
            {
                User* user = [self.filteredCreators objectAtIndex:indexPath.row];
                CLToken *token = [[CLToken alloc] initWithDisplayText:user.FormattedName context:user];
                [_currentInputView addToken:token];
                break;
            }
            case 4:
            {
                Portfolio* user = [self.filteredPortfolios objectAtIndex:indexPath.row];
                CLToken *token = [[CLToken alloc] initWithDisplayText:user.PortfolioName context:user];
                [_currentInputView addToken:token];
                break;
            }
            case 5:
            {
                Project* user = [self.filteredProjects objectAtIndex:indexPath.row];
                CLToken *token = [[CLToken alloc] initWithDisplayText:user.ProjectName context:user];
                [_currentInputView addToken:token];
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView selectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)toogleIncludeDoneTasks:(UIButton*)btn
{
    btn.selected = !btn.selected;
}

- (void)toogleFilterOptions:(UIButton*)btn
{
    btn.selected = !btn.selected;
    if(btn.selected)
        [self.popOver setPopoverContentSize:CGSizeMake(self.popOver.popoverContentSize.width, 7*60)];
    
    _filterOpened = btn.selected;
    NSMutableArray* indexs = [NSMutableArray array];
    [indexs addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
    [indexs addObject:[NSIndexPath indexPathForRow:2 inSection:0]];
    [indexs addObject:[NSIndexPath indexPathForRow:3 inSection:0]];
    [indexs addObject:[NSIndexPath indexPathForRow:4 inSection:0]];
    [indexs addObject:[NSIndexPath indexPathForRow:5 inSection:0]];
    [indexs addObject:[NSIndexPath indexPathForRow:6 inSection:0]];
    if(_filterOpened)
    {
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:indexs withRowAnimation:UITableViewRowAnimationBottom];
        [tableView endUpdates];
    }
    else
    {
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:indexs withRowAnimation:UITableViewRowAnimationBottom];
        [tableView endUpdates];
        [self.popOver setPopoverContentSize:CGSizeMake(self.popOver.popoverContentSize.width, 100)];
    }
}


- (void)searchAction:(UIButton*)btn
{
    [self.view endEditing:YES];
    NSMutableDictionary* d = [NSMutableDictionary dictionary];
    [d setObject:_searchKeyword?_searchKeyword:@"" forKey:@"searchKey"];
    [d setObject:_wordKeyword?_wordKeyword:@"" forKey:@"wordKey"];
    [d setObject:self.selectedAssginee forKey:@"assignee"];
    [d setObject:self.selectedCreators forKey:@"creators"];
    [d setObject:self.selectedPortfolios forKey:@"portfolios"];
    [d setObject:self.selectedProjects forKey:@"project"];
    [d setObject:includeCompBtn.selected?@"1":@"0" forKey:@"includeDoneTask"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeFeedCallBackCallBack:) name:@"HomeFeedNotifier" object:nil];
    [[TaskDocument sharedInstance] setSearchCriteria:d];
    [[TaskDocument sharedInstance] refreshSearchFeed];
}

- (void)getHomeFeedCallBackCallBack:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(reloadView:) withObject:[note object] waitUntilDone:NO];
}

- (void)reloadView:(NSArray*)tmp
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.popOver dismissPopoverAnimated:YES];
}


@end
