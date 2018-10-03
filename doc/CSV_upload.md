
We can send data in bulk with the script:

`node post-readings.js 'https://api-staging.smartcitizen.me/v0' 4 12 'TOKEN' 1000`



## Benchmarks:

### Using Sidekiq on api-staging (2GB RAM)
|Data amount | HTTP (s) | Telnet (s)  |
|-|-|-|
|1    | 0     | 0 |
|10   | 0.18  | 0.15 |
|100  | 0.98  | 0.675 |
|1000 | 6 - 8 | 5 |
|10000| 50 - 94 | 30 |
|20000| see below| - |

Node script `post-readings.js` fails with > 14.000 lines of data with:

```
(node:19083) UnhandledPromiseRejectionWarning: FetchError: invalid json response body at https://api-staging.smartcitizen.me/v0/devices/4/readings reason: Unexpected token < in JSON at position 0
(node:19083) UnhandledPromiseRejectionWarning: Unhandled promise rejection. This error originated either by throwing inside of an async function without a catch block, or by rejecting a promise which was not handled with .catch(). (rejection id: 2)
(node:19083) [DEP0018] DeprecationWarning: Unhandled promise rejections are deprecated. In the future, promise rejections that are not handled will terminate the Node.js process with a non-zero exit code.

```
