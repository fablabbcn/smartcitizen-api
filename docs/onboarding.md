# Onboarding Process

## Start onboarding process (create orphan_device)

### POST /v0/onboarding/device

Method creates orphan_device and returns unique 'onboarding_session' and 'device_token'.
Requires no params at all, however, it can take any of the following: 'name', 'description', 'kit_id', 'exposure', 'latitude', 'longitude', 'user_tags'. Any passed params will be used on the creation of the 'orphan_device'.

Note that both 'device_token' and 'onboarding_session' are unique for each 'orphan_device'.
```
request example:
------------------------------
Content-Type: application/json
Accept: application/json
------------------------------
{
  "kit_id": 1
}
```

```
response example:

{
  "onboarding_session": "a562f6bb-4328-4d5b-bb9f-ea6bd8e592a8",
  "device_token": "d803e0"
}
```

## Update orphan_device

### PATCH /v0/onboarding/device

Method to update (slide by slide, or all at once) the still 'orphan' device.
It requires a valid 'Onboarding-Session' header and returns updated 'orphan_device' (status 200) if successfully updated.

Calling without an existent 'Onboarding-Session' returns error "Invalid onboarding_session" (404).
```
request example:
--------------------------------------------------------
Content-Type: application/json
Accept: application/json
OnboardingSession: a71095a2-e99c-4664-82d8-b4c1c9bbc531
--------------------------------------------------------
{
  "name": "Owner",
  "description": "device description",
  "kit_id": 1,
  "exposure": "indoor",
  "latitude": 41.3966908,
  "longitude": 2.1921909,
  "user_tags": "tag1,tag2"
}
```

```
response example:

{
  "id": 7,
  "name": "Owner",
  "description": "device description",
  "kit_id": 1,
  "exposure": "indoor",
  "latitude": 41.3966908,
  "longitude": 2.1921909,
  "user_tags": "tag1,tag2",
  "device_token": "e58956",
  "onboarding_session": "a71095a2-e99c-4664-82d8-b4c1c9bbc531",
  "created_at": "2016-10-29T11:55:42+02:00",
  "updated_at": "2016-10-29T11:55:42+02:00"
}
```

## Find existent user

### POST /v0/onboarding/user

Method that requires params 'email' and returns user 'username' if email is associated to an existent user (status 200).
If 'email' does not correspond to any user (404) 'not_found' is returned.

Calling without 'email' params results in a 422, "Missing Params".
```
request example:
------------------------------
Content-Type: application/json
Accept: application/json
------------------------------
{
  "email": "user1@email.com"
}
```

```
response example:

{
  "username": "user1"
}
```

## User login

In order to complete the 'Onboarding Process', it is required user authentication.

## Register device (add a new device to user using 'orphan_device')

### POST v0/onboarding/register

Method adds to the current_user a new 'device' using onboarding_session's correspondent 'orphan_device' attributes. It returns newly created 'device'.

If 'Onboarding-Session' is not valid, (404) "Invalid onboarding_session".

Requires user authentication, otherwise (401) "Authorization required" is returned.

Requires all the `/onboarding/device` parameters to be provided (`name`, `description`, `kit_id`, `exposure`, `latitude`, `longitude`, `user_tags`), otherwise results in a 422, "Missing Params".

```
POST v0/onboarding/register request example:

--------------------------------------------------------
Content-Type: application/json
Accept: application/json
OnboardingSession: a71095a2-e99c-4664-82d8-b4c1c9bbc531
--------------------------------------------------------
{}

```

```
response example:

{
  "id": 1,
  "owner_id": 2,
  "name": "OrphanDeviceName",
  "description": "OrphanDeviceDescription",
  "mac_address": nil,
  "latitude": 41.3966908,
  "longitude": 2.1921909,
  "created_at": "2016-10-29T12:31:25+02:00",
  "updated_at": "2016-10-29T12:31:25+02:00",
  "kit_id": 1,
  "latest_data": nil,
  "geohash": "sp3e9bh31y",
  "last_recorded_at": nil,
  "meta": {
    "exposure": "indoor"
  },
  "location": {
    "address": "Carrer de Pallars, 122, 08018 Barcelona, Barcelona, Spain",
    "city": "Barcelona",
    "postal_code": "08018",
    "state_name": "Catalunya",
    "state_code": "CT",
    "country_code": "ES"
  },
  "data": nil,
  "old_data": nil,
  "owner_username": "user2",
  "uuid": nil,
  "migration_data": nil,
  "workflow_state": "active",
  "csv_export_requested_at": nil,
  "old_mac_address": nil,
  "state": "not_configured"
}
```
This is the end of the onboarding process.

## Token notification

This is tiggered when the platform receives the first **"Hello World"** from the Kit after the *light setup* process. 

`io.connect(‘wss://smartcitizen.xyz’).on('token-received’, doSomething);``

### Example:

http://codepen.io/pral2a/pen/ObMWjG

### Angular Integration:

The SmartCitizen front-end features already a `push.service.js` that can be extended with minor changes:

https://github.com/fablabbcn/smartcitizen-web/blob/2e08faca25675970d56c0b5cc090670ffff73d47/src/app/core/api/push.service.js

This needs to extend as follows:

```
function devicesToken(then){
  socket.on('token-received', then);
}

function deviceToken(tokenID, scope){
  devicesToken(function(data){
    if(tokenID == data.device_token) scope.$emit('token', data);
  })
}
```

And use as follows:

`push.token(vm.kitData.token, $scope);`

By including the following service we will be also able to listen notification everytime the Kit published new data:

`push.device(vm.kitData.id, $scope);`








