# Authorization System Overview

We have a role-based authorization system for your Trays application with three components:

## 1. Role-Based Permissions (lib/trays/accounts.ex:333-367)

The Trays.Accounts.can?/3 function implements permission checks based on user roles:

Admin: Full access to everything
Merchant: Can manage menus and orders (manage and view actions on :menu and :orders)
Customer: Can create orders and view their own orders

## 2. Plug Authorization (lib/trays_web/plugs/authorize.ex)

For traditional Phoenix controllers:

`plug TraysWeb.Plugs.Authorize, action: :manage, resource: :menu`

Redirects to home with an error flash if unauthorized.

## 3. LiveView Hook (lib/trays_web/hooks/authorize.ex)

For LiveView pages:

`on_mount {TraysWeb.Hooks.Authorize, {:manage, :menu}}`

Handles authorization during LiveView mount, redirecting unauthorized users.

## Additional User Auth Features (lib/trays_web/user_auth.ex)

- `require_authenticated_user` - Basic authentication check
- `require_merchant` - Merchant role check (lines 287-298)
- `require_admin` - Admin role check (lines 305-316)

Session management with remember-me cookies

Sudo mode for sensitive operations
