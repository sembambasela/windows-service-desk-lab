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
- [ ] Sign in using `LabAdmin_01`.
- [ ] Open Computer Management → Local Users and Groups → Users.
- [ ] Create `jdoe` with a unique lab password (do not document the password).
- [ ] Verify membership in `Users`.
- [ ] Verify absence of membership in `Administrators`.
- [ ] Sign in as `jdoe` and confirm access.
- [ ] Capture screenshots of account and group membership (no secrets).
- [ ] Complete service request `../incident-reports/SR-002-user-provisioning.md`.

## Verification
- Account created: Pending
- Users group: Pending
- Not in Administrators group: Pending
- Successful sign-in: Pending

## Security principle
Least privilege: grant only the access required for the user's job.
