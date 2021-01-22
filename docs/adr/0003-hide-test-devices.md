- Deciders: pral2a oscgonfer
- Date: 2021-01-04

## Problem

- We have multiple 'test' devices that we create internally while developing features / testing sensors etc.
- We don't want these devices to show up on the World Map, because they are clutter / noise.
- The `is_test` field can also be used to quickly delete all test devices.

## Solution

- Add a boolean field `is_test` (or similar) to devices, that we can activate in order to hide devices.


## Thoughts

- Should our users also be able to do this themselves on their own devices?
   - Yes, but only users with ADMIN or RESEARCHER rights.
- We have the `is_private` but that shows devices on the World Map. Can we change is_private to also hide devices on the world_map?
