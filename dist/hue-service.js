"use strict";
angular.module("hue", []).service("hue", [
  "$http", "$q", "$log", function($http, $q, $log) {
    var buildApiUrl, config, getBridgeNupnp, isReady, _apiCall, _buildUrl, _del, _get, _post, _put, _responseHandler, _setup;
    config = {
      username: "",
      apiUrl: "",
      bridgeIP: ""
    };
    isReady = false;
    _setup = function() {
      var deferred;
      deferred = $q.defer();
      if (isReady) {
        deferred.resolve();
        return deferred.promise;
      }
      if (config.username === "") {
        $log.error("Error in setup: Username has to be set");
        deferred.reject;
        return deferred.promise;
      }
      if (config.apiUrl !== "") {
        isReady = true;
        deferred.resolve();
        return deferred.promise;
      }
      if (config.bridgeIP !== "") {
        config.apiUrl = buildApiUrl();
        isReady = true;
        deferred.resolve();
      } else {
        getBridgeNupnp().then(function(data) {
          if (data[0] != null) {
            config.bridgeIP = data[0].internalipaddress;
            config.apiUrl = buildApiUrl();
            isReady = true;
            return deferred.resolve();
          } else {
            $log.error("Error in setup: Returned data from nupnp is empty. Is there a hue bridge present in this network?");
            return deferred.reject;
          }
        }, function(error) {
          $log.error("Error in setup: " + error);
          return deferred.reject;
        });
      }
      return deferred.promise;
    };
    _put = function(name, url, data) {
      var deferred;
      deferred = $q.defer();
      $http.put(url, data).success(function(response) {
        return _responseHandler(name, response, deferred);
      }).error(function(response) {
        $log.error("Error: " + name, response);
        return deferred.reject;
      });
      return deferred.promise;
    };
    _post = function(name, url, data) {
      var deferred;
      deferred = $q.defer();
      $http.post(url, data).success(function(response) {
        return _responseHandler(name, response, deferred);
      }).error(function(response) {
        $log.error("Error: " + name, response);
        return deferred.reject;
      });
      return deferred.promise;
    };
    _del = function(name, url) {
      var deferred;
      deferred = $q.defer();
      $http["delete"](url).success(function(response) {
        return _responseHandler(name, response, deferred);
      }).error(function(response) {
        $log.error("Error: " + name, response);
        return deferred.reject;
      });
      return deferred.promise;
    };
    _get = function(name, url) {
      var deferred;
      deferred = $q.defer();
      $http.get(url).success(function(response) {
        return _responseHandler(name, response, deferred);
      }).error(function(response) {
        $log.error("" + name, response);
        return deferred.reject;
      });
      return deferred.promise;
    };
    _responseHandler = function(name, response, deferred) {
      if ((response[0] != null) && response[0].error) {
        $log.error("" + name, response);
        return deferred.reject;
      } else {
        $log.debug("Response of " + name + ":", response);
        return deferred.resolve(response);
      }
    };
    _buildUrl = function(urlParts) {
      var part, url, _i, _len;
      if (urlParts == null) {
        urlParts = [];
      }
      url = config.apiUrl;
      for (_i = 0, _len = urlParts.length; _i < _len; _i++) {
        part = urlParts[_i];
        url = url + ("/" + part);
      }
      return url;
    };
    _apiCall = function(method, path, params) {
      var name, url;
      if (path == null) {
        path = [];
      }
      if (params == null) {
        params = null;
      }
      name = method + path.join("/");
      url = _buildUrl(path);
      switch (method) {
        case "get":
          return _get(name, url);
        case "post":
          return _post(name, url, params);
        case "put":
          return _put(name, url, params);
        case "delete":
          return _del(name, url);
        default:
          return $log.error("unsupported method " + method);
      }
    };
    getBridgeNupnp = function() {
      return _get("getBridgeNupnp", "https://www.meethue.com/api/nupnp");
    };
    buildApiUrl = function() {
      return "http://" + config.bridgeIP + "/api/" + config.username;
    };
    this.getBridgeIP = function() {
      return _setup().then(function() {
        return config.bridgeIP;
      });
    };
    this.setup = function(newconfig) {
      if (newconfig == null) {
        newconfig = {};
      }
      return angular.extend(config, newconfig);
    };
    this.getLights = function() {
      return _setup().then(function() {
        return _apiCall("get", ['lights']);
      });
    };
    this.getNewLights = function() {
      return _setup().then(function() {
        return _apiCall("get", ['lights', 'new']);
      });
    };
    this.searchNewLights = function() {
      return _setup().then(function() {
        return _apiCall("post", ['lights'], {});
      });
    };
    this.getLight = function(id) {
      return _setup().then(function() {
        return _apiCall("get", ['lights', id]);
      });
    };
    this.setLightName = function(id, name) {
      return _setup().then(function() {
        return _apiCall("put", ['lights', id], {
          "name": name
        });
      });
    };
    this.setLightState = function(id, state) {
      return _setup().then(function() {
        return _apiCall("put", ["lights", id, "state"], state);
      });
    };
    this.getConfiguration = function() {
      return _setup().then(function() {
        return _apiCall("get", ["config"]);
      });
    };
    this.setConfiguration = function(configuration) {
      return _setup().then(function() {
        return _apiCall("put", ["config"], configuration);
      });
    };
    this.createUser = function(devicetype, username) {
      if (username == null) {
        username = false;
      }
      return _setup().then(function() {
        var user;
        user = {
          "devicetype": devicetype
        };
        if (username) {
          user.username = username;
        }
        return _apiCall("post", ["api"], user);
      });
    };
    this.deleteUser = function(username) {
      return _setup().then(function() {
        return _apiCall("delete", ["config", "whitelist", username]);
      });
    };
    this.getFullState = function() {
      return _setup().then(function() {
        return _apiCall("get");
      });
    };
    this.getGroups = function() {
      return _setup().then(function() {
        return _apiCall("get", ["groups"]);
      });
    };
    this.createGroup = function(name, lights) {
      return _setup().then(function() {
        var body;
        body = {
          "lights": lights,
          "name": name
        };
        $log.debug("Debug: createGroup body", body);
        return _apiCall("post", ["groups"], body);
      });
    };
    this.getGroupAttributes = function(id) {
      return _setup().then(function() {
        return _apiCall("get", ["groups", id]);
      });
    };
    this.setGroupAttributes = function(id, name, lights) {
      return _setup().then(function() {
        var body;
        body = {
          "lights": lights,
          "name": name
        };
        return _apiCall("put", ["groups", id], body);
      });
    };
    this.setGroupState = function(id, state) {
      return _setup().then(function() {
        return _apiCall("put", ["groups", id, "action"], state);
      });
    };
    this.deleteGroup = function(id) {
      return _setup().then(function() {
        return _apiCall("delete", ["groups", id]);
      });
    };
    this.getRules = function() {
      return _setup().then(function() {
        return _apiCall("get", ["rules"]);
      });
    };
    this.getRule = function(id) {
      return _setup().then(function() {
        return _apiCall("get", ["rules", id]);
      });
    };
    this.createRule = function(name, conditions, actions) {
      return _setup().then(function() {
        var body;
        body = {
          "name": name,
          "conditions": conditions,
          "actions": actions
        };
        return _apiCall("post", ["rules"], body);
      });
    };
    this.updateRule = function(id, name, conditions, actions) {
      if (name == null) {
        name = false;
      }
      if (conditions == null) {
        conditions = false;
      }
      if (actions == null) {
        actions = false;
      }
      return _setup().then(function() {
        var body;
        body = {};
        if (name) {
          body.name = name;
        }
        if (conditions) {
          body.conditions = conditions;
        }
        if (actions) {
          body.actions = actions;
        }
        $log.debug("Debug: updateRule body", body);
        return _apiCall("put", ["rules"], body);
      });
    };
    this.deleteRule = function(id) {
      return _setup().then(function() {
        return _apiCall("delete", ["rules", id]);
      });
    };
    this.getSchedules = function() {
      return _setup().then(function() {
        return _apiCall("get", ["schedules"]);
      });
    };
    this.createSchedule = function(name, description, command, time, status, autodelete) {
      if (name == null) {
        name = "schedule";
      }
      if (description == null) {
        description = "";
      }
      if (status == null) {
        status = "enabled";
      }
      if (autodelete == null) {
        autodelete = false;
      }
      return _setup().then(function() {
        var body;
        body = {
          "name": name,
          "description": description,
          "command": command,
          "time": time,
          "status": status,
          "autodelete": autodelete
        };
        return _apiCall("post", ["schedules"], body);
      });
    };
    this.getScheduleAttributes = function(id) {
      return _setup().then(function() {
        return _apiCall("get", ["schedules", id]);
      });
    };
    this.setScheduleAttributes = function(id, name, description, command, time, status, autodelete) {
      if (name == null) {
        name = null;
      }
      if (description == null) {
        description = null;
      }
      if (command == null) {
        command = null;
      }
      if (time == null) {
        time = null;
      }
      if (status == null) {
        status = null;
      }
      if (autodelete == null) {
        autodelete = null;
      }
      return _setup().then(function() {
        var body;
        body = {};
        if (name) {
          body.name = name;
        }
        if (description) {
          body.description = description;
        }
        if (command) {
          body.command = command;
        }
        if (status) {
          body.status = status;
        }
        if (autodelete !== null) {
          body.autodelete = autodelete;
        }
        return _apiCall("put", ["schedules", id], body);
      });
    };
    this.deleteSchedule = function(id) {
      return _setup().then(function() {
        return _apiCall("delete", ["schedules", id]);
      });
    };
    this.getScenes = function() {
      return _setup().then(function() {
        return _apiCall("get", ["scenes"]);
      });
    };
    this.createScene = function(id, name, lights) {
      return _setup().then(function() {
        var body;
        body = {
          "name": name,
          "lights": lights
        };
        return _apiCall("put", ["scenes", id], body);
      });
    };
    this.updateScene = function(id, light, state) {
      return _setup().then(function() {
        return _apiCall("put", ["scenes", id, "lights", light, "state"], state);
      });
    };
    this.getSensors = function() {
      return _setup().then(function() {
        return _apiCall("get", ["sensors"]);
      });
    };
    this.createSensor = function(name, modelid, swversion, type, uniqueid, manufacturername, state, config) {
      if (state == null) {
        state = null;
      }
      if (config == null) {
        config = null;
      }
      return _setup().then(function() {
        var body;
        body = {
          "name": name,
          "modelid": modelid,
          "swversion": swversion,
          "type": type,
          "uniqueid": uniqueid,
          "manufacturername": manufacturername
        };
        if (state) {
          body.state = state;
        }
        if (config) {
          body.config = config;
        }
        return _apiCall("post", ["sensors"], body);
      });
    };
    this.searchNewSensors = function() {
      return _setup().then(function() {
        return _apiCall("post", ["sensors"], null);
      });
    };
    this.getNewSensors = function() {
      return _setup().then(function() {
        return _apiCall("get", ["sensors", "new"]);
      });
    };
    this.getSensor = function(id) {
      return _setup().then(function() {
        return _apiCall("get", ["sensors", id]);
      });
    };
    this.renameSensor = function(id, name) {
      return _setup().then(function() {
        var body;
        body = {
          "name": name
        };
        return _apiCall("put", ["sensors", id], body);
      });
    };
    this.updateSensor = function(id, config) {
      return _setup().then(function() {
        return _apiCall("put", ["sensors", id, "config"], config);
      });
    };
    this.setSensorState = function(id, state) {
      return _setup().then(function() {
        return _apiCall("put", ["sensors", id, "state"], state);
      });
    };
    this.getTimezones = function() {
      return _setup().then(function() {
        return _apiCall("get", ["info", "timezones"]);
      });
    };
    this.setEffect = function(id, effect) {
      if (effect == null) {
        effect = "none";
      }
      return setLightState(id, {
        "effect": effect
      });
    };
    this.setAlert = function(id, alert) {
      if (alert == null) {
        alert = "none";
      }
      return setLightState(id, {
        "alert": alert
      });
    };
    this.setBrightness = function(id, brightness) {
      return setLightState(id, {
        "bri": brightness
      });
    };
  }
]);
