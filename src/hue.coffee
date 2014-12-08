angular.module("hue", []).service "hue", [
  "$http"
  "$q"
  ($http, $q) ->
    username = "newdeveloper" # TODO: implement app registration
    apiUrl = ""
    bridgeIP = ""
    isReady = false
    debug = true

    _setup = ->
      deferred = $q.defer()
      if isReady
        deferred.resolve()
      else
        getBridgeNupnp().then (data) ->
          bridgeIP = data[0].internalipaddress
          apiUrl = "http://#{bridgeIP}/api/#{username}"
          isReady = true
          deferred.resolve()
      deferred.promise

    _put = (name, url, data) ->
      deferred = $q.defer()
      $http.put(url, data)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          console.log "Error: #{name}", response if debug
          deferred.reject
      deferred.promise

    _post = (name, url, data) ->
      deferred = $q.defer()
      $http.post(url, data)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          console.log "Error: #{name}", response if debug
          deferred.reject
      deferred.promise

    _del = (name, url) ->
      deferred = $q.defer()
      $http.delete(url)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          console.log "Error: #{name}", response if debug
          deferred.reject
      deferred.promise

    _get = (name, url) ->
      deferred = $q.defer()
      $http.get(url)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          console.log "Error: #{name}", response if debug
          deferred.reject
      deferred.promise

    _responseHandler = (name, response, deferred) ->
      if response[0]? && response[0].error
        console.log "Error: #{name}", response if debug
        deferred.reject
      else
        console.log "Debug: #{name}", response if debug
        deferred.resolve response

    getBridgeNupnp = ->
      _get "getBridgeNupnp", "https://www.meethue.com/api/nupnp"
    
    @getBridgeIP = ->
      _setup().then ->
        bridgeIP


    # http://www.developers.meethue.com/documentation/lights-api#11_get_all_lights
    @getLights = ->
      _setup().then ->
        _get "getLights", "#{apiUrl}/lights"

    # http://www.developers.meethue.com/documentation/lights-api#12_get_new_lights
    @getNewLights = ->
      _setup().then ->
        _get "getNewLights", "#{apiUrl}/lights/new"

    # http://www.developers.meethue.com/documentation/lights-api#13_search_for_new_lights
    @searchNewLights = ->
      _setup().then ->
        _post "searchNewLights", "#{apiUrl}/lights", {}

    # http://www.developers.meethue.com/documentation/lights-api#14_get_light_attributes_and_state
    @getLight = (id) ->
      _setup().then ->
        _get "getLight", "#{apiUrl}/lights/#{id}"

    # http://www.developers.meethue.com/documentation/lights-api#15_set_light_attributes_rename
    @setLightName = (id, name) ->
      _setup().then ->
        body = {"name": name}
        _put "setLightName", "#{apiUrl}/lights/#{id}", body

    # http://www.developers.meethue.com/documentation/lights-api#16_set_light_state
    @setLightState = (id, state) ->
      _setup().then ->
        _put "setLightState", "#{apiUrl}/lights/#{id}/state", state


    # http://www.developers.meethue.com/documentation/configuration-api#72_get_configuration
    @getConfiguration = ->
      _setup().then ->
        _get "getConfiguration", "#{apiUrl}/config"

    # http://www.developers.meethue.com/documentation/configuration-api#73_modify_configuration
    @setConfiguration = (configuration) ->
      _setup().then ->
        _put "setConfiguration", "#{apiUrl}/config", configuration

    # http://www.developers.meethue.com/documentation/configuration-api#71_create_user
    @createUser = (devicetype, username=false) ->
      _setup().then ->
        user = {"devicetype": devicetype}
        user.username = username if username
        _post "createUser", "http://#{bridgeIP}/api", user

    # http://www.developers.meethue.com/documentation/configuration-api#74_delete_user_from_whitelist
    @deleteUser = (username) ->
      _setup().then ->
        _del "deleteUser", "#{apiUrl}/config/whitelist/#{username}"

    # http://www.developers.meethue.com/documentation/configuration-api#75_get_full_state_datastore
    @getFullState = ->
      _setup().then ->
        _get "getFullState", apiUrl


    # http://www.developers.meethue.com/documentation/groups-api#21_get_all_groups
    @getGroups = ->
      _setup().then ->
        _get "getGroups", "#{apiUrl}/groups"

    # http://www.developers.meethue.com/documentation/groups-api#22_create_group
    @createGroup = (name, lights) ->
      _setup().then ->
        body = {
          "lights": lights
          "name": name
        }
        console.log "Debug: createGroup body", body if debug
        _post "createGroup", "#{apiUrl}/groups", body

    # http://www.developers.meethue.com/documentation/groups-api#23_get_group_attributes
    @getGroupAttributes = (id) ->
      _setup().then ->
        _get "getGroupAttributes", "#{apiUrl}/groups/#{id}"

    # http://www.developers.meethue.com/documentation/groups-api#24_set_group_attributes
    @setGroupAttributes = (id, name, lights) ->
      _setup().then ->
        body = {
          "lights": lights
          "name": name
        }
        _put "setGroupAttributes", "#{apiUrl}/groups/#{id}", body

    # http://www.developers.meethue.com/documentation/groups-api#25_set_group_state
    @setGroupState = (id, state) ->
      _setup().then ->
        _put "setGroupState", "#{apiUrl}/groups/#{id}/action", state

    # http://www.developers.meethue.com/documentation/groups-api#26_delete_group
    @deleteGroup = (id) ->
      _setup().then ->
        _del "deleteUser", "#{apiUrl}/groups/#{id}"


    # rules-api
    # http://www.developers.meethue.com/documentation/rules-api#61_get_all_rules
    @getRules = ->
      _setup().then ->
        _get "getRules", "#{apiUrl}/rules"

    # http://www.developers.meethue.com/documentation/rules-api#62_get_rule
    @getRule = (id) ->
      _setup().then ->
        _get "getRule", "#{apiUrl}/rules/#{id}"

    # http://www.developers.meethue.com/documentation/rules-api#63_create_rule
    @createRule = (name, conditions, actions) ->
      _setup().then ->
        body = {
          "name": name
          "conditions": conditions
          "actions": actions
        }
        _post "createRule", "#{apiUrl}/rules", body

    # http://www.developers.meethue.com/documentation/rules-api#64_update_rule
    @updateRule = (id, name=false, conditions=false, actions=false) ->
      _setup().then ->
        body = {}
        body.name = name if name
        body.conditions = conditions if conditions
        body.actions = actions if actions
        console.log "Debug: updateRule body", body if debug
        _put "updateRule", "#{apiUrl}/rules", body

    # http://www.developers.meethue.com/documentation/rules-api#65_delete_rule
    @deleteRule = (id) ->
      _setup().then ->
        _del "deleteRule", "#{apiUrl}/rules/#{id}"


    # http://www.developers.meethue.com/documentation/schedules-api-0#31_get_all_schedules
    @getSchedules = ->
      _setup().then ->
        _get "getSchedules", "#{apiUrl}/schedules"

    # http://www.developers.meethue.com/documentation/schedules-api-0#32_create_schedule
    # TODO: strip whitespace from command
    @createSchedule = (name="schedule", description="", command, time, status="enabled", autodelete=false) ->
      _setup().then ->
        body = {
          "name": name
          "description": description
          "command": command
          "time": time
          "status": status
          "autodelete": autodelete
        }
        _post "createSchedule", "#{apiUrl}/schedules", body

    # http://www.developers.meethue.com/documentation/schedules-api-0#33_get_schedule_attributes
    @getScheduleAttributes = (id) ->
      _setup().then ->
        _get "getScheduleAttributes", "#{apiUrl}/schedules/#{id}"

    # http://www.developers.meethue.com/documentation/schedules-api-0#34_set_schedule_attributes
    @setScheduleAttributes = (id, name=null, description=null, command=null, time=null, status=null, autodelete=null) ->
      _setup().then ->
        body = {}
        body.name = name if name
        body.description = description if description
        body.command = command if command
        body.status = status if status
        body.autodelete = autodelete if autodelete != null
        _put "setScheduleAttributes", "#{apiUrl}/schedules/#{id}", body

    # http://www.developers.meethue.com/documentation/schedules-api-0#35_delete_schedule
    @deleteSchedule = (id) ->
      _setup().then ->
        _del "deleteSchedule", "#{apiUrl}/schedules/#{id}"


    # http://www.developers.meethue.com/documentation/scenes-api#41_get_all_scenes
    @getScenes = ->
      _setup().then ->
        _get "getScenes", "#{apiUrl}/scenes"

    # http://www.developers.meethue.com/documentation/scenes-api#42_create_scene
    @createScene = (id, name, lights) ->
      _setup().then ->
        body = {
          "name": name
          "lights": lights
        }
        _put "createScene", "#{apiUrl}/scenes/#{id}", body

    # http://www.developers.meethue.com/documentation/scenes-api#43_modify_scene
    @updateScene = (id, light, state) ->
      _setup().then ->
        _put "updateScene", "#{apiUrl}/scenes/#{id}/lights/#{light}/state", state


    # http://www.developers.meethue.com/documentation/sensors-api#51_get_all_sensors
    @getSensors = ->
      _setup().then ->
        _get "getSensors", "#{apiUrl}/sensors"

    # http://www.developers.meethue.com/documentation/sensors-api#52_create_sensor
    @createSensor = (name, modelid, swversion, type, uniqueid, manufacturername, state=null, config=null) ->
      _setup().then ->
        body = {
          "name": name
          "modelid": modelid
          "swversion": swversion
          "type": type
          "uniqueid": uniqueid
          "manufacturername": manufacturername
        }
        body.state = state if state
        body.config = config if config
        _post "createSensor", "#{apiUrl}/sensors", body

    # http://www.developers.meethue.com/documentation/sensors-api#53_autodiscover_sensors
    @searchNewSensors = ->
      _setup().then ->
        _post "searchNewSensors", "#{apiUrl}/sensors", null

    # http://www.developers.meethue.com/documentation/sensors-api#54_getnew_sensors
    @getNewSensors = ->
      _setup().then ->
        _get "getNewSensors", "#{apiUrl}/sensors/new"

    # http://www.developers.meethue.com/documentation/sensors-api#55_get_sensor
    @getSensor = (id) ->
      _setup().then ->
        _get "getSensor", "#{apiUrl}/sensors/#{id}"

    # http://www.developers.meethue.com/documentation/sensors-api#56_update_sensor
    @renameSensor = (id, name) ->
      _setup().then ->
        body = {
          "name": name
        }
        _put "renameSensor", "#{apiUrl}/sensors/#{id}", body

    # http://www.developers.meethue.com/documentation/sensors-api#58_change_sensor_config
    @updateSensor = (id, config) ->
      _setup().then ->
        _put "updateSensor", "#{apiUrl}/sensors/#{id}/config", config

    @setSensorState = (id, state) ->
      _setup().then ->
        _put "setSensorState", "#{apiUrl}/sensors/#{id}/state", state

    # http://www.developers.meethue.com/documentation/info-api#81_get_all_timezones
    @getTimezones = ->
      _setup().then ->
        _get "getTimezones", "#{apiUrl}/info/timezones"

    return
]