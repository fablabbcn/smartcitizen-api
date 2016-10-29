# Onboarding Process

## Start onboarding process (create orphan_device)

POST /v0/onboarding/device

Method creates orphan_device and returns unique 'onboarding_session' and 'device_token'.
Requires no params at all, however, it can take any of the following: 'name', 'description',
'kit_id', 'exposure', 'latitude', 'longitude', 'user_tags'. Any passed params will be used on the creation of the 'orphan_device'.

Note that both 'device_token' and 'onboarding_session' are unique for each 'orphan_device'.
```
payload example:

{
  "kit_id": 1
}
```

```
response example:

{
  "onboarding_session" => "a562f6bb-4328-4d5b-bb9f-ea6bd8e592a8",
  "device_token" => "d803e0"
}
```

## Update orphan_device

PATCH /v0/onboarding/device

Method to update (slide by slide, or all at once) the still 'orphan' device.
It only requires a valid 'onboarding_session' and returns updated 'orphan_device' (status 200) if successfully updated.

Calling without 'onboarding_session' returns error "Missing Params" (422).
Calling without an existent 'onboarding_session' returns error "Invalid onboarding_session" (404).
```
payload example:

{
  "onboarding_session": "a71095a2-e99c-4664-82d8-b4c1c9bbc531",
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
  "id" => 7,
  "name" => "Owner",
  "description" => "device description",
  "kit_id" => 1,
  "exposure" => "indoor",
  "latitude" => 41.3966908,
  "longitude" => 2.1921909,
  "user_tags" => "tag1,tag2",
  "device_token" => "e58956",
  "onboarding_session" => "a71095a2-e99c-4664-82d8-b4c1c9bbc531",
  "created_at" => "2016-10-29T11:55:42+02:00",
  "updated_at" => "2016-10-29T11:55:42+02:00"
}
```

## Find existent user

POST /v0/onboarding/user

Method that requires params 'email' and 'onboarding_session' and returns user 'username' if email
is associated to an existent user (status 200).
If 'email' does not correspond to any user (404) 'not_found' is returned.

Calling without either 'email' or 'onboarding_session' params results in a 422, "Missing Params".
Calling without an existent 'onboarding_session' returns error "Invalid onboarding_session" (404).
```
payload example:

{
  "onboarding_session": "a71095a2-e99c-4664-82d8-b4c1c9bbc531",
  "email": "user1@email.com"
}
```

```
response example:

{
  "username" => "user1"
}
```

## User login

Before completing the 'onboarding_session' it is required user to authenticate. For new users
(those that username has not been returned) using existent registration process is required
POST v0/users.
Regardless of user is new or not authorization credentials are required and the 'access_token' must
be obtained using POST v0/sessions.

## Register device (add a new device to user using 'orphan_device')

POST v0/onboarding/register

Method takes 'access_token' and 'onboarding_session' and adds to the current_user a new 'device'
using onboarding_session's correspondent 'orphan_device' attributes. It returns newly created
'device'.

If 'access_token' is not valid or missing, (401) "Authorization required" is returned.
If 'onboarding_session' is not valid, (404) "Invalid onboarding_session".

```
payload example:

{
  "onboarding_session": "a71095a2-e99c-4664-82d8-b4c1c9bbc531",
  "access_token": "abd729a81160e0654482662d55cc65ead2e6f28785efd160bd089d44cd9037d2"
}
```

```
response example:

{
  "id" => 1,
  "owner_id" => 2,
  "name" => "OrphanDeviceName",
  "description" => "OrphanDeviceDescription",
  "mac_address" => nil,
  "latitude" => 41.3966908,
  "longitude" => 2.1921909,
  "created_at" => "2016-10-29T12:31:25+02:00",
  "updated_at" => "2016-10-29T12:31:25+02:00",
  "kit_id" => 1,
  "latest_data" => nil,
  "geohash" => "sp3e9bh31y",
  "last_recorded_at" => nil,
  "meta" => {
    "exposure" => "indoor"
  },
  "location" => {
    "address" => "Carrer de Pallars, 122, 08018 Barcelona, Barcelona, Spain",
    "city" => "Barcelona",
    "postal_code" => "08018",
    "state_name" => "Catalunya",
    "state_code" => "CT",
    "country_code" => "ES"
  },
  "data" => nil,
  "old_data" => nil,
  "owner_username" => "user2",
  "uuid" => nil,
  "migration_data" => nil,
  "workflow_state" => "active",
  "csv_export_requested_at" => nil,
  "old_mac_address" => nil,
  "state" => "not_configured"
}
```
This is the end of the onboarding process.
