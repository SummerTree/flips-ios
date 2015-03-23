//
//  MBContactPicker.m
//  MBContactPicker
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "MBContactPicker.h"
#import "Flips-Swift.h"

CGFloat const kMaxVisibleRows = 2;
NSString * const kMBPrompt = @"To:";
CGFloat const kAnimationSpeed = .25;
static NSString *const ContactTableViewCellIdentifier = @"ContactTableViewCell";
static CGFloat const ROW_HEIGHT = 56.0;

#define NO_CONTACTS NSLocalizedString(@"No contacts found.  Please try again.", @"No contacts")
#define NO_MATCHES NSLocalizedString(@"No Matches", @"No Matches")
#define OK NSLocalizedString(@"OK", @"OK")


@interface MBContactPicker()

@property (nonatomic, weak) MBContactCollectionView *contactCollectionView;
@property (nonatomic, weak) UITableView *searchTableView;
@property (nonatomic) NSArray *filteredContacts;
@property (nonatomic) NSArray *contacts;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGSize contactCollectionViewContentSize;

@property CGFloat originalHeight;
@property CGFloat originalYOffset;

@property (nonatomic) BOOL hasLoadedData;

@end

@implementation MBContactPicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)didMoveToWindow
{
    if (self.window)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardChangedStatus:) name:UIKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardChangedStatus:) name:UIKeyboardWillHideNotification object:nil];
        
        if (!self.hasLoadedData)
        {
            [self reloadData];
            self.hasLoadedData = YES;
        }
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if (newWindow == nil)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)setup
{
    _prompt = kMBPrompt;
    _showPrompt = YES;
    
    self.originalHeight = -1;
    self.originalYOffset = -1;
    self.maxVisibleRows = kMaxVisibleRows;
    self.animationSpeed = kAnimationSpeed;
    self.allowsCompletionOfSelectedContacts = YES;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.clipsToBounds = YES;
    self.enabled = YES;
    
    MBContactCollectionView *contactCollectionView = [MBContactCollectionView contactCollectionViewWithFrame:self.bounds];
    contactCollectionView.contactDelegate = self;
    contactCollectionView.backgroundColor = self.backgroundColor;
    contactCollectionView.clipsToBounds = YES;
    contactCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contactCollectionView];
    self.contactCollectionView = contactCollectionView;

    UITableView *searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 0)];
    searchTableView.dataSource = self;
    searchTableView.delegate = self;
    searchTableView.translatesAutoresizingMaskIntoConstraints = NO;
    searchTableView.hidden = YES;
    searchTableView.rowHeight = ROW_HEIGHT;
    searchTableView.separatorInset = UIEdgeInsetsZero;
    searchTableView.tableFooterView = [UIView new];
    [searchTableView registerNib:[UINib nibWithNibName:@"ContactTableViewCell" bundle:nil] forCellReuseIdentifier:ContactTableViewCellIdentifier];
    [self addSubview:searchTableView];
    self.searchTableView = searchTableView;
    
    
    [contactCollectionView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [searchTableView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[contactCollectionView(>=%ld,<=%ld)][searchTableView(>=0)]|", (long)self.cellHeight, (long)self.cellHeight]
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(contactCollectionView, searchTableView)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contactCollectionView]-(0@500)-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(contactCollectionView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contactCollectionView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(contactCollectionView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchTableView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(searchTableView)]];
    
    
#ifdef DEBUG_BORDERS
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1.0;
    contactCollectionView.layer.borderColor = [UIColor redColor].CGColor;
    contactCollectionView.layer.borderWidth = 1.0;
    searchTableView.layer.borderColor = [UIColor blueColor].CGColor;
    searchTableView.layer.borderWidth = 1.0;
#endif
}

#pragma mark - Keyboard Notification Handling
- (void)keyboardChangedStatus:(NSNotification*)notification
{
    CGRect keyboardRect;
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardRect];
    self.keyboardHeight = keyboardRect.size.height;
}

- (void)reloadData
{
    self.contactCollectionView.selectedContacts = [[NSMutableArray alloc] init];
    
    if ([self.datasource respondsToSelector:@selector(selectedContactModelsForContactPicker:)])
    {
        [self.contactCollectionView.selectedContacts addObjectsFromArray:[self.datasource selectedContactModelsForContactPicker:self]];
    }
    
    self.contacts = [self.datasource contactModelsForContactPicker:self];
    
    [self.contactCollectionView reloadData];
    [self.contactCollectionView performBatchUpdates:^{
    } completion:^(BOOL finished) {
        [self.contactCollectionView scrollToEntryAnimated:NO onComplete:nil];
    }];
}

- (NSString*)phoneNumberFromText:(NSString*)text
{
    if ([text length] > 10) //whitespace before and at least 10 digits
    {
        NSString *maybePhoneNumber = [PhoneNumberHelper cleanFormattedPhoneNumber:text];
        if ([maybePhoneNumber length] >= 10 && [maybePhoneNumber length] <= 12)
        {
            maybePhoneNumber = [PhoneNumberHelper formatUsingUSInternational:maybePhoneNumber];
            NSString *maybeJustDigits = [maybePhoneNumber substringFromIndex:1];
            NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *entryString = [NSCharacterSet characterSetWithCharactersInString:maybeJustDigits];
            BOOL isPhoneNumber = [digits isSupersetOfSet:entryString];
            if (isPhoneNumber)
            {
                return maybePhoneNumber;
            }
        }
    }
    return nil;
}

#pragma mark - Properties

- (NSArray*)contactsSelected
{
    return self.contactCollectionView.selectedContacts;
}

- (void)setCellHeight:(NSInteger)cellHeight
{
    self.contactCollectionView.cellHeight = cellHeight;
    [self.contactCollectionView.collectionViewLayout invalidateLayout];
}

- (NSInteger)cellHeight
{
    return self.contactCollectionView.cellHeight;
}

- (void)setPrompt:(NSString *)prompt
{
    _prompt = [prompt copy];
    self.contactCollectionView.prompt = _prompt;
}

- (void)setMaxVisibleRows:(CGFloat)maxVisibleRows
{
    _maxVisibleRows = maxVisibleRows;
    [self.contactCollectionView.collectionViewLayout invalidateLayout];
}

- (CGFloat)currentContentHeight
{
    CGFloat minimumSizeWithContent = MAX(self.cellHeight, self.contactCollectionViewContentSize.height);
    CGFloat maximumSize = self.maxVisibleRows * self.cellHeight;
    return MIN(minimumSizeWithContent, maximumSize);
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    self.contactCollectionView.allowsSelection = enabled;
    self.contactCollectionView.allowsTextInput = enabled;
    
    if (!enabled)
    {
        [self resignFirstResponder];
    }
}

- (void)setShowPrompt:(BOOL)showPrompt
{
    _showPrompt = showPrompt;
    self.contactCollectionView.showPrompt = showPrompt;
}

- (BOOL)isInvalidContact {
    return self.contactCollectionView.isInvalidContact;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredContacts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactTableViewCellIdentifier forIndexPath:indexPath];

    Contact<MBContactPickerModelProtocol> *contact = (Contact<MBContactPickerModelProtocol> *)self.filteredContacts[indexPath.row];

    cell.nameLabel.text = contact.contactTitle;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    cell.photoView.initials = contact.contactInitials;
    
    User *user = contact.contactUser;
    
    if (user) {
        // Flips user
        cell.photoView.borderColor = [UIColor flipOrange];
        
        NSString *photoURLString = user.photoURL;
        
        if (photoURLString) {
            NSURL *url = [NSURL URLWithString:photoURLString];
            if (url) {
                [cell.photoView setImageWithURL:url success:nil];
            }
        }

        cell.numberLabel.text = [NSString stringWithFormat:@"(%@)", [user fullName]];
    } else {
        cell.photoView.borderColor = [UIColor lightGreyD8];
        
        if ([contact respondsToSelector:@selector(contactSubtitle)]) {
            cell.numberLabel.text = contact.contactSubtitle;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MBContactPickerModelProtocol> model = self.filteredContacts[indexPath.row];
    
    [self hideSearchTableView];
    [self.contactCollectionView addToSelectedContacts:model withCompletion:^{
        [self becomeFirstResponder];
    }];
}

#pragma mark - ContactCollectionViewDelegate

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView willChangeContentSizeTo:(CGSize)newSize
{
    if (!CGSizeEqualToSize(self.contactCollectionViewContentSize, newSize))
    {
        self.contactCollectionViewContentSize = newSize;
        [self updateCollectionViewHeightConstraints];
        
        if ([self.delegate respondsToSelector:@selector(contactPicker:didUpdateContentHeightTo:)])
        {
            [self.delegate contactPicker:self didUpdateContentHeightTo:self.currentContentHeight];
        }
    }
}

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView entryTextDidChange:(NSString*)text
{
    if ([text isEqualToString:@" "])
    {
        [self hideSearchTableView];
    }
    else
    {
        [self.contactCollectionView.collectionViewLayout invalidateLayout];
        
        [self.contactCollectionView performBatchUpdates:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.contactCollectionView setFocusOnEntry];
        }];
        
        [self showSearchTableView];
        NSString *searchString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSPredicate *predicate;
        if (self.allowsCompletionOfSelectedContacts) {
            predicate = [NSPredicate predicateWithFormat:@"contactTitle contains[cd] %@", searchString];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"contactTitle contains[cd] %@ && !SELF IN %@", searchString, self.contactCollectionView.selectedContacts];
        }
        
        NSString* phoneNumber = [self phoneNumberFromText:text];
        if (phoneNumber != nil)
        {
            ContactDataSource* dataSource = [[ContactDataSource alloc] init];
            NSArray* phoneNumberArray = [dataSource retrieveContactsWithPhoneNumber:phoneNumber];
            if (phoneNumberArray.count == 0)
            {
                [[PersistentManager sharedInstance] createOrUpdateContactWith:phoneNumber lastName:nil phoneNumber:phoneNumber phoneType:@"" andContactUser:nil];
                phoneNumberArray = [dataSource retrieveContactsWithPhoneNumber:phoneNumber];
            }
            self.filteredContacts = [phoneNumberArray arrayByAddingObjectsFromArray:[self.contacts filteredArrayUsingPredicate:predicate]];
        }
        else
        {
            self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
        }
        
        [self.searchTableView reloadData];
    }
    
    if ([self.delegate respondsToSelector:@selector(contactPicker:didChangeEntryText:)]) {
        [self.delegate contactPicker:self didChangeEntryText:text];
    }
}

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didRemoveContact:(id<MBContactPickerModelProtocol>)model
{
    if ([self.delegate respondsToSelector:@selector(contactCollectionView:didRemoveContact:)])
    {
        [self.delegate contactCollectionView:contactCollectionView didRemoveContact:model];
    }
}

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didAddContact:(id<MBContactPickerModelProtocol>)model
{
    if ([self.delegate respondsToSelector:@selector(contactCollectionView:didAddContact:)])
    {
        [self.delegate contactCollectionView:contactCollectionView didAddContact:model];
    }
}

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didSelectContact:(id<MBContactPickerModelProtocol>)model
{
    if ([self.delegate respondsToSelector:@selector(contactCollectionView:didSelectContact:)])
    {
        [self.delegate contactCollectionView:contactCollectionView didSelectContact:model];
    }
}

- (BOOL)contactCollectionView:(MBContactCollectionView *)contactCollectionView textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0 &&
        ![textField.text isEqual:@" "] &&
        self.filteredContacts.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NO_MATCHES
                                                            message:NO_CONTACTS
                                                           delegate:nil
                                                  cancelButtonTitle:OK
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }
    
    if (self.filteredContacts.count) {
        id<MBContactPickerModelProtocol> model = [self.filteredContacts firstObject];
        
        [self hideSearchTableView];
        [self.contactCollectionView addToSelectedContacts:model withCompletion:nil];
    }
    
    return YES;
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

- (BOOL)becomeFirstResponder
{
    if (!self.enabled)
    {
        return NO;
    }
    
    if (![self isFirstResponder])
    {
        if (self.contactCollectionView.indexPathOfSelectedCell)
        {
            [self.contactCollectionView scrollToItemAtIndexPath:self.contactCollectionView.indexPathOfSelectedCell atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        }
        else
        {
            [self.contactCollectionView setFocusOnEntry];
        }
    }
    
    return YES;
}

- (BOOL)resignFirstResponder
{
    return [self.contactCollectionView resignFirstResponder];
}

#pragma mark Helper Methods

- (void)showSearchTableView
{
    self.searchTableView.hidden = NO;
    if ([self.delegate respondsToSelector:@selector(didShowFilteredContactsForContactPicker:)])
    {
        [self.delegate didShowFilteredContactsForContactPicker:self];
    }
}

- (void)hideSearchTableView
{
    self.searchTableView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didHideFilteredContactsForContactPicker:)])
    {
        [self.delegate didHideFilteredContactsForContactPicker:self];
    }
}

- (void)updateCollectionViewHeightConstraints
{
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (constraint.firstItem == self.contactCollectionView)
        {
            if (constraint.firstAttribute == NSLayoutAttributeHeight)
            {
                if (constraint.relation == NSLayoutRelationGreaterThanOrEqual)
                {
                    constraint.constant = self.cellHeight;
                }
                else if (constraint.relation == NSLayoutRelationLessThanOrEqual)
                {
                    constraint.constant = self.currentContentHeight;
                }
            }
        }
    }
}

@end
