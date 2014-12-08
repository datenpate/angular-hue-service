angular.module("hue", []).service "hue", [
  "$http"
  "$q"
  ($http, $q) ->
    config = {
      username: "newdeveloper"
      debug: true
      apiUrl: ""
      bridgeIP: ""
    }
    isReady = false

    _setup = ->
      deferred = $q.defer()
      if isReady
        deferred.resolve()
      else
        if config.apiUrl == ""
          getBridgeNupnp().then (data) ->
            config.bridgeIP = data[0].internalipaddress
            config.apiUrl = "http://#{config.bridgeIP}/api/#{config.username}"
            isReady = true
            deferred.resolve()
        else
          isReady = true
          deferred.resolve()
      deferred.promise

    _put = (name, url, data) ->
      deferred = $q.defer()
      $http.put(url, data)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          console.log "Error: #{name}", response if config.debug
          deferred.reject
      deferred.promise

    _post = (name, url, data) ->
      deferred = $q.defer()
      $http.post(url, data)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          console.log "Error: #{name}", response if config.debug
          deferred.reject
      deferred.promise

    _del = (name, url) ->
      deferred = $q.defer()
      $http.delete(url)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          console.log "Error: #{name}", response if config.debug
          deferred.reject
      deferred.promise

    _get = (name, url) ->
      deferred = $q.defer()
      $http.get(url)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          console.log "Error: #{name}", response if config.debug
          deferred.reject
      deferred.promise

    _responseHandler = (name, response, deferred) ->
      if response[0]? && response[0].error
        console.log "Error: #{name}", response if config.debug
        deferred.reject
      else
        console.log "Debug: #{name}", response if config.debug
        deferred.resolve response

    getBridgeNupnp = ->
      _get "getBridgeNupnp", "https://www.meethue.com/api/nupnp"
    
    @getBridgeIP = ->
      _setup().then ->
        config.bridgeIP

    @setup = (newconfig={}) ->
      angular.extend config, newconfig


    # http://www.developers.meethue.com/documentation/lights-api#11_get_all_lights
    @getLights = ->
      _setup().then ->
        _get "getLights", "#{config.apiUrl}/lights"

    # http://www.developers.meethue.com/documentation/lights-api#12_get_new_lights
    @getNewLights = ->
      _setup().then ->
        _get "getNewLights", "#{config.apiUrl}/lights/new"

    # http://www.developers.meethue.com/documentation/lights-api#13_search_for_new_lights
    @searchNewLights = ->
      _setup().then ->
        _post "searchNewLights", "#{config.apiUrl}/lights", {}

    # http://www.developers.meethue.com/documentation/lights-api#14_get_light_attributes_and_state
    @getLight = (id) ->
      _setup().then ->
        _get "getLight", "#{config.apiUrl}/lights/#{id}"

    # http://www.developers.meethue.com/documentation/lights-api#15_set_light_attributes_rename
    @setLightName = (id, name) ->
      _setup().then ->
        body = {"name": name}
        _put "setLightName", "#{config.apiUrl}/lights/#{id}", body

    # http://www.developers.meethue.com/documentation/lights-api#16_set_light_state
    @setLightState = (id, state) ->
      _setup().then ->
        _put "setLightState", "#{config.apiUrl}/lights/#{id}/state", state


    # http://www.developers.meethue.com/documentation/configuration-api#72_get_configuration
    @getConfiguration = ->
      _setup().then ->
        _get "getConfiguration", "#{config.apiUrl}/config"

    # http://www.developers.meethue.com/documentation/configuration-api#73_modify_configuration
    @setConfiguration = (configuration) ->
      _setup().then ->
        _put "setConfiguration", "#{config.apiUrl}/config", configuration

    # http://www.developers.meethue.com/documentation/configuration-api#71_create_user
    @createUser = (devicetype, username=false) ->
      _setup().then ->
        user = {"devicetype": devicetype}
        user.username = username if username
        _post "createUser", "http://#{config.bridgeIP}/api", user

    # http://www.developers.meethue.com/documentation/configuration-api#74_delete_user_from_whitelist
    @deleteUser = (username) ->
      _setup().then ->
        _del "deleteUser", "#{config.apiUrl}/config/whitelist/#{username}"

    # http://www.developers.meethue.com/documentation/configuration-api#75_get_full_state_datastore
    @getFullState = ->
      _setup().then ->
        _get "getFullState", config.apiUrl


    # http://www.developers.meethue.com/documentation/groups-api#21_get_all_groups
    @getGroups = ->
      _setup().then ->
        _get "getGroups", "#{config.apiUrl}/groups"

    # http://www.developers.meethue.com/documentation/groups-api#22_create_group
    @createGroup = (name, lights) ->
      _setup().then ->
        body = {
          "lights": lights
          "name": name
        }
        console.log "Debug: createGroup body", body if config.debug
        _post "createGroup", "#{config.apiUrl}/groups", body

    # http://www.developers.meethue.com/documentation/groups-api#23_get_group_attributes
    @getGroupAttributes = (id) ->
      _setup().then ->
        _get "getGroupAttributes", "#{config.apiUrl}/groups/#{id}"

    # http://www.developers.meethue.com/documentation/groups-api#24_set_group_attributes
    @setGroupAttributes = (id, name, lights) ->
      _setup().then ->
        body = {
          "lights": lights
          "name": name
        }
        _put "setGroupAttributes", "#{config.apiUrl}/groups/#{id}", body

    # http://www.developers.meethue.com/documentation/groups-api#25_set_group_state
    @setGroupState = (id, state) ->
      _setup().then ->
        _put "setGroupState", "#{config.apiUrl}/groups/#{id}/action", state

    # http://www.developers.meethue.com/documentation/groups-api#26_delete_group
    @deleteGroup = (id) ->
      _setup().then ->
        _del "deleteUser", "#{config.apiUrl}/groups/#{id}"


    # rules-api
    # http://www.developers.meethue.com/documentation/rules-api#61_get_all_rules
    @getRules = ->
      _setup().then ->
        _get "getRules", "#{config.apiUrl}/rules"

    # http://www.developers.meethue.com/documentation/rules-api#62_get_rule
    @getRule = (id) ->
      _setup().then ->
        _get "getRule", "#{config.apiUrl}/rules/#{id}"

    # http://www.developers.meethue.com/documentation/rules-api#63_create_rule
    @createRule = (name, conditions, actions) ->
      _setup().then ->
        body = {
          "name": name
          "conditions": conditions
          "actions": actions
        }
        _post "createRule", "#{config.apiUrl}/rules", body

    # http://www.developers.meethue.com/documentation/rules-api#64_update_rule
    @updateRule = (id, name=false, conditions=false, actions=false) ->
      _setup().then ->
        body = {}
        body.name = name if name
        body.conditions = conditions if conditions
        body.actions = actions if actions
        console.log "Debug: updateRule body", body if config.debug
        _put "updateRule", "#{config.apiUrl}/rules", body

    # http://www.developers.meethue.com/documentation/rules-api#65_delete_rule
    @deleteRule = (id) ->
      _setup().then ->
        _del "deleteRule", "#{config.apiUrl}/rules/#{id}"


    # http://www.developers.meethue.com/documentation/schedules-api-0#31_get_all_schedules
    @getSchedules = ->
      _setup().then ->
        _get "getSchedules", "#{config.apiUrl}/schedules"

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
        _post "createSchedule", "#{config.apiUrl}/schedules", body

    # http://www.developers.meethue.com/documentation/schedules-api-0#33_get_schedule_attributes
    @getScheduleAttributes = (id) ->
      _setup().then ->
        _get "getScheduleAttributes", "#{config.apiUrl}/schedules/#{id}"

    # http://www.developers.meethue.com/documentation/schedules-api-0#34_set_schedule_attributes
    @setScheduleAttributes = (id, name=null, description=null, command=null, time=null, status=null, autodelete=null) ->
      _setup().then ->
        body = {}
        body.name = name if name
        body.description = description if description
        body.command = command if command
        body.status = status if status
        body.autodelete = autodelete if autodelete != null
        _put "setScheduleAttributes", "#{config.apiUrl}/schedules/#{id}", body

    # http://www.developers.meethue.com/documentation/schedules-api-0#35_delete_schedule
    @deleteSchedule = (id) ->
      _setup().then ->
        _del "deleteSchedule", "#{config.apiUrl}/schedules/#{id}"


    # http://www.developers.meethue.com/documentation/scenes-api#41_get_all_scenes
    @getScenes = ->
      _setup().then ->
        _get "getScenes", "#{config.apiUrl}/scenes"

    # http://www.developers.meethue.com/documentation/scenes-api#42_create_scene
    @createScene = (id, name, lights) ->
      _setup().then ->
        body = {
          "name": name
          "lights": lights
        }
        _put "createScene", "#{config.apiUrl}/scenes/#{id}", body

    # http://www.developers.meethue.com/documentation/scenes-api#43_modify_scene
    @updateScene = (id, light, state) ->
      _setup().then ->
        _put "updateScene", "#{config.apiUrl}/scenes/#{id}/lights/#{light}/state", state


    # http://www.developers.meethue.com/documentation/sensors-api#51_get_all_sensors
    @getSensors = ->
      _setup().then ->
        _get "getSensors", "#{config.apiUrl}/sensors"

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
        _post "createSensor", "#{config.apiUrl}/sensors", body

    # http://www.developers.meethue.com/documentation/sensors-api#53_autodiscover_sensors
    @searchNewSensors = ->
      _setup().then ->
        _post "searchNewSensors", "#{config.apiUrl}/sensors", null

    # http://www.developers.meethue.com/documentation/sensors-api#54_getnew_sensors
    @getNewSensors = ->
      _setup().then ->
        _get "getNewSensors", "#{config.apiUrl}/sensors/new"

    # http://www.developers.meethue.com/documentation/sensors-api#55_get_sensor
    @getSensor = (id) ->
      _setup().then ->
        _get "getSensor", "#{config.apiUrl}/sensors/#{id}"

    # http://www.developers.meethue.com/documentation/sensors-api#56_update_sensor
    @renameSensor = (id, name) ->
      _setup().then ->
        body = {
          "name": name
        }
        _put "renameSensor", "#{config.apiUrl}/sensors/#{id}", body

    # http://www.developers.meethue.com/documentation/sensors-api#58_change_sensor_config
    @updateSensor = (id, config) ->
      _setup().then ->
        _put "updateSensor", "#{config.apiUrl}/sensors/#{id}/config", config

    @setSensorState = (id, state) ->
      _setup().then ->
        _put "setSensorState", "#{config.apiUrl}/sensors/#{id}/state", state

    # http://www.developers.meethue.com/documentation/info-api#81_get_all_timezones
    @getTimezones = ->
      _setup().then ->
        _get "getTimezones", "#{config.apiUrl}/info/timezones"

    return
]