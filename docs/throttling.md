Throttling is done as follows:
- If the request is unauthenticated or the authorisation level doesn't allow it, `role_mask == 1`, the request is throttled at a rate of 150 requests/ minute
- If the request is authorised with a `role_mask >= 2` (`researcher` or `admin`), the request is not throttled and it will do so based on the request remote ip for 5'

This implies that if `role_mask>=2` requests are followed by unauthenticated or unauthorised requests from the same IP, those requests will not be throttled - we consider this a borderline case.
Also, if an IP is throttled - returning 429s, a request `role_mask>=2` coming from that IP will get a 429 until 1' passes.
