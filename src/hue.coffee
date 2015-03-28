"use strict"
angular.module("hue", []).service "hue", [
  "$http"
  "$q"
  "$log"
  ($http, $q, $log) ->
    config =
      username: ""
      apiUrl: ""
      bridgeIP: ""

    isReady = false

    _setup = ->
      deferred = $q.defer()
      if isReady
        deferred.resolve()
        return deferred.promise
      if config.username == ""
        $log.error "Error in setup: Username has to be set"
        deferred.reject
        return deferred.promise
      if config.apiUrl != ""
        isReady = true
        deferred.resolve()
        return deferred.promise
      if config.bridgeIP != ""
        config.apiUrl = buildApiUrl()
        isReady = true
        deferred.resolve()
      else
        getBridgeNupnp().then (data) ->
          # TODO: handle multiple bridges
          if data[0]?
            config.bridgeIP = data[0].internalipaddress
            config.apiUrl = buildApiUrl()
            isReady = true
            deferred.resolve()
          else
            $log.error "Error in setup: Returned data from nupnp is empty. Is there a hue bridge present in this network?"
            deferred.reject
        , (error) ->
          $log.error "Error in setup: #{error}"
          deferred.reject
      deferred.promise

    _put = (name, url, data) ->
      deferred = $q.defer()
      $http.put(url, data)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          $log.error "Error: #{name}", response
          deferred.reject
      deferred.promise

    _post = (name, url, data) ->
      deferred = $q.defer()
      $http.post(url, data)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          $log.error "Error: #{name}", response
          deferred.reject
      deferred.promise

    _del = (name, url) ->
      deferred = $q.defer()
      $http.delete(url)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          $log.error "Error: #{name}", response
          deferred.reject
      deferred.promise

    _get = (name, url) ->
      deferred = $q.defer()
      $http.get(url)
        .success (response) ->
          _responseHandler name, response, deferred
        .error (response) ->
          $log.error "#{name}", response
          deferred.reject
      deferred.promise

    _responseHandler = (name, response, deferred) ->
      if response[0]? && response[0].error
        $log.error "#{name}", response
        deferred.reject
      else
        $log.debug "Response of #{name}:", response
        deferred.resolve response

    _buildUrl = (urlParts=[]) ->
      url = config.apiUrl
      for part in urlParts
        url = url + "/#{part}"
      return url

    _apiCall = (method, path=[], params=null) ->
      name = method + path.join("/")
      url = _buildUrl(path)
      switch method
        when "get"
          _get name, url
        when "post"
          _post name, url, params
        when "put"
          _put name, url, params
        when "delete"
          _del name, url
        else
          $log.error "unsupported method #{method}"

    getBridgeNupnp = ->
      _get "getBridgeNupnp", "https://www.meethue.com/api/nupnp"

    buildApiUrl = () ->
      "http://#{config.bridgeIP}/api/#{config.username}"
    
    @getBridgeIP = ->
      _setup().then ->
        config.bridgeIP

    @setup = (newconfig={}) ->
      angular.extend config, newconfig


    # Get all lights
    # http://www.developers.meethue.com/documentation/lights-api#11_get_all_lights
    #
    # @return [promise]
    @getLights = ->
      _setup().then ->
        _apiCall "get", ['lights']

    # http://www.developers.meethue.com/documentation/lights-api#12_get_new_lights
    @getNewLights = ->
      _setup().then ->
        _apiCall "get", ['lights', 'new']

    # http://www.developers.meethue.com/documentation/lights-api#13_search_for_new_lights
    @searchNewLights = ->
      _setup().then ->
        _apiCall "post", ['lights'], {}

    # Get a light
    # http://www.developers.meethue.com/documentation/lights-api#14_get_light_attributes_and_state
    #
    # @param [Integer] id light id
    @getLight = (id) ->
      _setup().then ->
        _apiCall "get", ['lights', id]


    # http://www.developers.meethue.com/documentation/lights-api#15_set_light_attributes_rename
    @setLightName = (id, name) ->
      _setup().then ->
        _apiCall "put", ['lights', id], {"name": name}

    # http://www.developers.meethue.com/documentation/lights-api#16_set_light_state
    @setLightState = (id, state) ->
      # TODO: build a model for state
      _setup().then ->
        _apiCall "put", ["lights", id, "state"], state

    # http://www.developers.meethue.com/documentation/configuration-api#72_get_configuration
    @getConfiguration = ->
      _setup().then ->
        _apiCall "get", ["config"]

    # http://www.developers.meethue.com/documentation/configuration-api#73_modify_configuration
    @setConfiguration = (configuration) ->
      # TODO: build a model for configuration
      _setup().then ->
        _apiCall "put", ["config"], configuration

    # http://www.developers.meethue.com/documentation/configuration-api#71_create_user
    @createUser = (devicetype, username=false) ->
      _setup().then ->
        user = {"devicetype": devicetype}
        user.username = username if username
        _apiCall "post", ["api"], user

    # http://www.developers.meethue.com/documentation/configuration-api#74_delete_user_from_whitelist
    @deleteUser = (username) ->
      _setup().then ->
        _apiCall "delete", ["config", "whitelist", username]

    # http://www.developers.meethue.com/documentation/configuration-api#75_get_full_state_datastore
    @getFullState = ->
      _setup().then ->
        _apiCall "get"


    # http://www.developers.meethue.com/documentation/groups-api#21_get_all_groups
    @getGroups = ->
      _setup().then ->
        _apiCall "get", ["groups"]

    # http://www.developers.meethue.com/documentation/groups-api#22_create_group
    @createGroup = (name, lights) ->
      # TODO: build a model for lights
      _setup().then ->
        body = {
          "lights": lights
          "name": name
        }
        $log.debug "Debug: createGroup body", body
        _apiCall "post", ["groups"], body

    # http://www.developers.meethue.com/documentation/groups-api#23_get_group_attributes
    @getGroupAttributes = (id) ->
      _setup().then ->
        _apiCall "get", ["groups", id]

    # http://www.developers.meethue.com/documentation/groups-api#24_set_group_attributes
    @setGroupAttributes = (id, name, lights) ->
      # TODO: build a model for lights
      _setup().then ->
        body = {
          "lights": lights
          "name": name
        }
        _apiCall "put", ["groups", id], body

    # http://www.developers.meethue.com/documentation/groups-api#25_set_group_state
    @setGroupState = (id, state) ->
      # TODO: build a model for state
      _setup().then ->
        _apiCall "put", ["groups", id, "action"], state

    # http://www.developers.meethue.com/documentation/groups-api#26_delete_group
    @deleteGroup = (id) ->
      _setup().then ->
        _apiCall "delete", ["groups", id]


    # rules-api
    # http://www.developers.meethue.com/documentation/rules-api#61_get_all_rules
    @getRules = ->
      _setup().then ->
        _apiCall "get", ["rules"]

    # http://www.developers.meethue.com/documentation/rules-api#62_get_rule
    @getRule = (id) ->
      _setup().then ->
        _apiCall "get", ["rules", id]

    # http://www.developers.meethue.com/documentation/rules-api#63_create_rule
    @createRule = (name, conditions, actions) ->
      # TODO: build a model for conditions and actions
      _setup().then ->
        body = {
          "name": name
          "conditions": conditions
          "actions": actions
        }
        _apiCall "post", ["rules"], body

    # http://www.developers.meethue.com/documentation/rules-api#64_update_rule
    @updateRule = (id, name=false, conditions=false, actions=false) ->
      _setup().then ->
        body = {}
        body.name = name if name
        body.conditions = conditions if conditions
        body.actions = actions if actions
        $log.debug "Debug: updateRule body", body
        _apiCall "put", ["rules"], body

    # http://www.developers.meethue.com/documentation/rules-api#65_delete_rule
    @deleteRule = (id) ->
      _setup().then ->
        _apiCall "delete", ["rules", id]


    # http://www.developers.meethue.com/documentation/schedules-api-0#31_get_all_schedules
    @getSchedules = ->
      _setup().then ->
        _apiCall "get", ["schedules"]

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
        _apiCall "post", ["schedules"], body

    # http://www.developers.meethue.com/documentation/schedules-api-0#33_get_schedule_attributes
    @getScheduleAttributes = (id) ->
      _setup().then ->
        _apiCall "get", ["schedules", id]

    # http://www.developers.meethue.com/documentation/schedules-api-0#34_set_schedule_attributes
    @setScheduleAttributes = (id, name=null, description=null, command=null, time=null, status=null, autodelete=null) ->
      _setup().then ->
        body = {}
        body.name = name if name
        body.description = description if description
        body.command = command if command
        body.status = status if status
        body.autodelete = autodelete if autodelete != null
        _apiCall "put", ["schedules", id], body

    # http://www.developers.meethue.com/documentation/schedules-api-0#35_delete_schedule
    @deleteSchedule = (id) ->
      _setup().then ->
        _apiCall "delete", ["schedules", id]


    # http://www.developers.meethue.com/documentation/scenes-api#41_get_all_scenes
    @getScenes = ->
      _setup().then ->
        _apiCall "get", ["scenes"]

    # http://www.developers.meethue.com/documentation/scenes-api#42_create_scene
    @createScene = (id, name, lights) ->
      # TODO: build a model for lights
      _setup().then ->
        body = {
          "name": name
          "lights": lights
        }
        _apiCall "put", ["scenes", id], body

    # http://www.developers.meethue.com/documentation/scenes-api#43_modify_scene
    @updateScene = (id, light, state) ->
      # TODO: build a model for state
      _setup().then ->
        _apiCall "put", ["scenes", id, "lights", light, "state"], state


    # http://www.developers.meethue.com/documentation/sensors-api#51_get_all_sensors
    @getSensors = ->
      _setup().then ->
        _apiCall "get", ["sensors"]

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
        _apiCall "post", ["sensors"], body

    # http://www.developers.meethue.com/documentation/sensors-api#53_autodiscover_sensors
    @searchNewSensors = ->
      _setup().then ->
        _apiCall "post", ["sensors"], null

    # http://www.developers.meethue.com/documentation/sensors-api#54_getnew_sensors
    @getNewSensors = ->
      _setup().then ->
        _apiCall "get", ["sensors", "new"]

    # http://www.developers.meethue.com/documentation/sensors-api#55_get_sensor
    @getSensor = (id) ->
      _setup().then ->
        _apiCall "get", ["sensors", id]

    # http://www.developers.meethue.com/documentation/sensors-api#56_update_sensor
    @renameSensor = (id, name) ->
      _setup().then ->
        body = {
          "name": name
        }
        _apiCall "put", ["sensors", id], body

    # http://www.developers.meethue.com/documentation/sensors-api#58_change_sensor_config
    @updateSensor = (id, config) ->
      # TODO: build a model for config
      _setup().then ->
        _apiCall "put", ["sensors", id, "config"], config

    @setSensorState = (id, state) ->
      # TODO: build a model for state
      _setup().then ->
        _apiCall "put", ["sensors", id, "state"], state

    # http://www.developers.meethue.com/documentation/info-api#81_get_all_timezones
    @getTimezones = ->
      _setup().then ->
        _apiCall "get", ["info", "timezones"]


    # Extras
    # light states

    # effect: "none"|"colorloop"
    @setEffect = (id, effect="none") ->
      setLightState id, {"effect": effect}

    # alert: "none"|"select"|"lselect"
    @setAlert = (id, alert="none") ->
      setLightState id, {"alert": alert}

    @setBrightness = (id, brightness) ->
      setLightState id, {"bri": brightness}

    return
]