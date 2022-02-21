# Lists

## Goal

Change the association of categories/items from users to a list which can be updated by multiple users.

## Table Changes

### Create lists table
- `id` int
- `name` string

### Create list permissions
- `id` int
- `list_id` int
- `user_id` int
- `spoilers` boolean (flag to indicate if same user can see claim view)

### Update categories
- Add `list_id` int
- Remove `user_id`

### Migration
1. Create tables
2. Copy user names as new list name records
3. Create list permissions from new list and user association
4. Remove `user_id` from `categories` and `items`

## UI/API Changes

### User side list
Pull lists vs. users. No link on current selection.

### Edit View and Claim View
Switch user_id param to list_id. Update associated services.
Need new way to switch between edit and claim views for users with both permission.
