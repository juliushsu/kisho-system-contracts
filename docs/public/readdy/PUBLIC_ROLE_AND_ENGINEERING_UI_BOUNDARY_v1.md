# Public Role & Engineering UI Boundary v1

## Generic roles

| Capability | Operator | Store Manager | Engineer |
|---|---|---|---|
| Daily status and operating workflow | yes | yes | only when explicitly scoped |
| Refill workflow | yes | yes | maintenance scope |
| Store price and business reports | no | yes | no default access |
| Catalog/asset sync status | view | view | diagnostics scope for manual action |
| Store topology editor | no | when authorized | support scope only |
| Network/provisioning/update tools | no | no | exact private scope required |

The frontend never grants authority. Every protected route/action handles server denial safely.

## Privileged UX pattern

For public UI mockups, a privileged action shows:

1. current target and state;
2. proposed change and old/new diff;
3. reason field;
4. step-up/confirmation placeholder;
5. pending/success/failure result with audit reference.

Do not include real credentials, reusable PINs, raw tokens, arbitrary shell, host scanner, unrestricted file manager, APK browser or raw telemetry.

## Session presentation

Show remaining privileged-session time and explicit exit. Timeout, logout or reboot returns to the ordinary operational UI. Do not persist an engineering session in the mockup.

