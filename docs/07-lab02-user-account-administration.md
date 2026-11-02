# Lab 02 — Local User Account Administration

**Status: Planned — not yet executed**

## Service request
- Ticket: SR-002
- Category: Identity and Access Management
- Request: New employee local account provisioning
- Priority: Low

## Scenario
A fictional employee, Jordan Doe, requires a standard local Windows account on `DESKTOP-0200R7P`.

## Account requirements
| Attribute | Value |
|---|---|
| Username | `jdoe` |
| Full name | Jordan Doe |
| Description | Standard employee account - Lab 02 |
| Required group | Users |
| Administrator membership | Not permitted |

## Procedure
- [X] Open Computer Management → Local Users and Groups → Users.
- [X] Create `jdoe` with a unique lab password (do not document the password).
- [X] Verify membership in `Users`.
- [X] Verify absence of membership in `Administrators`.
- [X] Sign in as `jdoe` and confirm access.
- [X] Capture screenshots of account and group membership (no secrets).
- [X] Complete service request `../incident-reports/SR-002-user-provisioning.md`.

## Verification
- Account created: Pending
- Users group: Pending
- Not in Administrators group: Pending
- Successful sign-in: Pending

## Security principle
Least privilege: grant only the access required for the user's job.

## Service Request Resolution — SR-002

**Category:** Identity and Access Management (IAM)  
**Request Type:** New User Provisioning  
**Status:** Resolved  
**Assigned Technician:** Lab Administrator

### Work Performed

1. Created local Windows account `jdoe` for simulated employee Jordan Doe.
2. Assigned standard user privileges through membership in the local Users group.
3. Verified that the account was not a member of the Administrators group.
4. Successfully authenticated to Windows 11 using the new account.
5. Executed `whoami` to confirm the active user identity.
6. Executed `whoami /groups` to inspect the account's effective security group memberships.
7. Attempted to launch Windows Terminal with administrative privileges.
8. Confirmed that Windows User Account Control requested administrator credentials before allowing elevation.

### Verification Results

**Account authentication:** Passed  
**Standard user permissions:** Passed  
**Group membership verification:** Passed  
**Administrative elevation restriction:** Passed

### Resolution Summary

Successfully provisioned and verified a standard local Windows user account. The employee account can access the workstation without possessing administrative privileges.

Windows User Account Control correctly required separate administrator credentials when elevated access was requested.

The account follows the principle of least privilege.

**Final Ticket Status:** Resolved

### Skills Demonstrated

- Local user provisioning
- Windows account administration
- Identity and Access Management
- Security group verification
- User Account Control
- Principle of least privilege
- Service request resolution and documentation
