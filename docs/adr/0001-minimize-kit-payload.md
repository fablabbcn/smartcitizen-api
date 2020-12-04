- Deciders: vicobarberan
- Date: 2020-12-03

## Why?

- Try do reduce the payload that gets sent from a device to the API by ~35%.
- Instead, the API will convert the new data type into JSON.


New payload example:
- https://github.com/fablabbcn/smartcitizen-kit-21/commit/f195dbc010c8cddc419cb4357875c9de942aab48#diff-f978f2d74f7bc8854e6bb019c93369fa30b05808be6de85f5571b5cc804db18fR414


```
￼{
  t:2017-03-24T13:35:14Z,
  29:48.45,
  13:66,
  12:28,
  10:4.45
}
```

Old payload:
- https://github.com/fablabbcn/smartcitizen-kit-21/blob/master/esp/src/SckESP.cpp#L361-L373

```json
 {	"data":[
 		{"recorded_at":"2017-03-24T13:35:14Z",
 			"sensors":[
 				{"id":29,"value":48.45},
 				{"id":13,"value":66},
 				{"id":12,"value":28},
 				{"id":10,"value":4.45}
 			]
 		}
 	]
 }
```
