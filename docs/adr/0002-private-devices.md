- Deciders: pral2a
- Date: 2019-09-01

## Problem

- Some devices might contain data you don't want to be public.
   - Example: How often / when you turn on the lights in your bathroom?

## Solution

- Add a boolean field `is_private` to devices, that can be used to hide their data.

Who can see a private device data?
- The data is only visible to the owner + admins

What about the World Map?
- The device name + location will be visible to EVERYONE on the World Map, but not it's data.
