
We can send data in bulk with the script:

`node post-readings.js 'https://api-staging.smartcitizen.me/v0' 4 12 'TOKEN' 1000`



## Benchmarks:

### Using the HTTP API
|Data amount | seconds |
|-|-|
|1 | 0.07 |
|10 | 0.18 |
|100 | 0.98 |
|1000| 6.2 |
|10000| |
