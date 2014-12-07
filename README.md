## AngularJS service to access Philips Hue API
Complete Hue API 1.4.0 (http://www.developers.meethue.com/philips-hue-api) as AngularJS service.

## Examples
```javascript
// Get all lights
hue.getLights().then(function(lights) {
	$scope.lights = lights;

  // Switch light 1 on
  hue.setLightState(1, {"on", true}).then(function(response) {
    $scope.lights[1].state.on = true;
    console.log('API response: ', response);
  });
});

```

## Build
Install Node.js and then

```sh
npm install
grunt build
```