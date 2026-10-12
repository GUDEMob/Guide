# Accommodation frontend demo

Open the student **Accommodation** tab, then **Open student portal**. The
**Open manager demo** link switches to a simulated property manager. No new
backend, migration, account role, or external service is required.

The demo stores viewing requests, transfer requests, status timelines,
membership, accommodation history, notices, messages, and notifications in one
`shared_preferences` JSON snapshot on this browser/device. Existing current-home
details are imported when the demo is first opened. Student name comes from the
existing role service; the student number must be entered because signup does
not store it.

Approval and completion are separate actions. Approval leaves the current home
unchanged. After a move-in is scheduled, the manager can confirm it on or after
the effective date. Repeating confirmation does not create another history
record. The student's private demo notice board follows their current demo
membership. Opening a listing profile is recorded separately from a physical
viewing; the latter requires a scheduled visit, student attendance indication,
and manager confirmation.

This is **not suitable for real resident data or production use**. There is no
server-side identity, manager authorisation, shared multi-device persistence,
transactional database, live property inventory, verified capacity, booking,
real property contact details or photos, email delivery, or secure private
notice-board enforcement. The manager switch is intentionally available to
anyone on the device. In-app notifications are local demo records and are not
integrated with the app's separate mock nudge screen. A backend would need to
own these rules and audit records before real accommodation onboarding.

Run the focused checks from the frontend directory:

```powershell
flutter test test/accommodation_demo_store_test.dart test/accommodation_sheet_test.dart test/accommodation_portal_widget_test.dart
flutter analyze lib/features/accommodation lib/core/router/app_router.dart
```
