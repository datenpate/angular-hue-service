"use strict"
angular.module "HueExample", ['hue']
.config ['$logProvider', ($logProvider) ->
  $logProvider.debugEnabled(true);
]
.controller 'MainController', ($scope, hue) ->
  myHue = hue

  myHue.setup
    username: "newdeveloper"

  myHue.getLights().then (lights) ->
    $scope.lights = lights

    $scope.setLightStateOn = (light, state) ->
      myHue.setLightState(light, {on: state}).then () ->
        $scope.lights[light].state.on = state

    $scope.triggerAlert = (light, alert) ->
      myHue.setLightState light, {"alert": alert}

    $scope.setEffect = (light, effect) ->
      myHue.setLightState(light, {"effect": effect}).then () ->
        $scope.lights[light].state.effect = effect

    changeBrightness = (light, value) ->
      myHue.setLightState light, {"bri": value}
    lazyChangeBrightness = _.debounce changeBrightness, 600

    $scope.changeBrightness = (light, value) ->
      lazyChangeBrightness light, value

    myHue.getGroups().then (groups) ->
      $scope.groups = groups

      $scope.deleteGroup = (group) ->
        myHue.deleteGroup(group).then () ->
          delete $scope.groups[group]

      $scope.setGroupStateOn = (group, state) ->
        myHue.setGroupState(group, {on: state}).then () ->
          $scope.groups[group].action.on = state

          angular.forEach $scope.groups[group].lights, (value) ->
            $scope.lights[value].state.on = state
