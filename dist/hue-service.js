angular.module("hue", []).service("hue", [
  "$http", "$q", function($http, $q) {
    var config, getBridgeNupnp, isReady, _del, _get, _post, _put, _responseHandler, _setup;
    config = {
      username: "newdeveloper",
      debug: true,
      apiUrl: "",
      bridgeIP: ""
    };
    isReady = false;
    _setup = function() {
      var deferred;
      deferred = $q.defer();
      if (isReady) {
        deferred.resolve();
      } else {
        getBridgeNupnp().then(function(data) {
          config.bridgeIP = data[0].internalipaddress;
          config.apiUrl = "http://" + config.bridgeIP + "/api/" + config.username;
          isReady = true;
          return deferred.resolve();
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
        if (config.debug) {
          console.log("Error: " + name, response);
        }
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
        if (config.debug) {
          console.log("Error: " + name, response);
        }
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
        if (config.debug) {
          console.log("Error: " + name, response);
        }
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
        if (config.debug) {
          console.log("Error: " + name, response);
        }
        return deferred.reject;
      });
      return deferred.promise;
    };
    _responseHandler = function(name, response, deferred) {
      if ((response[0] != null) && response[0].error) {
        if (config.debug) {
          console.log("Error: " + name, response);
        }
        return deferred.reject;
      } else {
        if (config.debug) {
          console.log("Debug: " + name, response);
        }
        return deferred.resolve(response);
      }
    };
    getBridgeNupnp = function() {
      return _get("getBridgeNupnp", "https://www.meethue.com/api/nupnp");
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
      return angular.extend(config(newconfig));
    };
    this.getLights = function() {
      return _setup().then(function() {
        return _get("getLights", "" + config.apiUrl + "/lights");
      });
    };
    this.getNewLights = function() {
      return _setup().then(function() {
        return _get("getNewLights", "" + config.apiUrl + "/lights/new");
      });
    };
    this.searchNewLights = function() {
      return _setup().then(function() {
        return _post("searchNewLights", "" + config.apiUrl + "/lights", {});
      });
    };
    this.getLight = function(id) {
      return _setup().then(function() {
        return _get("getLight", "" + config.apiUrl + "/lights/" + id);
      });
    };
    this.setLightName = function(id, name) {
      return _setup().then(function() {
        var body;
        body = {
          "name": name
        };
        return _put("setLightName", "" + config.apiUrl + "/lights/" + id, body);
      });
    };
    this.setLightState = function(id, state) {
      return _setup().then(function() {
        return _put("setLightState", "" + config.apiUrl + "/lights/" + id + "/state", state);
      });
    };
    this.getConfiguration = function() {
      return _setup().then(function() {
        return _get("getConfiguration", "" + config.apiUrl + "/config");
      });
    };
    this.setConfiguration = function(configuration) {
      return _setup().then(function() {
        return _put("setConfiguration", "" + config.apiUrl + "/config", configuration);
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
        return _post("createUser", "http://" + config.bridgeIP + "/api", user);
      });
    };
    this.deleteUser = function(username) {
      return _setup().then(function() {
        return _del("deleteUser", "" + config.apiUrl + "/config/whitelist/" + username);
      });
    };
    this.getFullState = function() {
      return _setup().then(function() {
        return _get("getFullState", config.apiUrl);
      });
    };
    this.getGroups = function() {
      return _setup().then(function() {
        return _get("getGroups", "" + config.apiUrl + "/groups");
      });
    };
    this.createGroup = function(name, lights) {
      return _setup().then(function() {
        var body;
        body = {
          "lights": lights,
          "name": name
        };
        if (config.debug) {
          console.log("Debug: createGroup body", body);
        }
        return _post("createGroup", "" + config.apiUrl + "/groups", body);
      });
    };
    this.getGroupAttributes = function(id) {
      return _setup().then(function() {
        return _get("getGroupAttributes", "" + config.apiUrl + "/groups/" + id);
      });
    };
    this.setGroupAttributes = function(id, name, lights) {
      return _setup().then(function() {
        var body;
        body = {
          "lights": lights,
          "name": name
        };
        return _put("setGroupAttributes", "" + config.apiUrl + "/groups/" + id, body);
      });
    };
    this.setGroupState = function(id, state) {
      return _setup().then(function() {
        return _put("setGroupState", "" + config.apiUrl + "/groups/" + id + "/action", state);
      });
    };
    this.deleteGroup = function(id) {
      return _setup().then(function() {
        return _del("deleteUser", "" + config.apiUrl + "/groups/" + id);
      });
    };
    this.getRules = function() {
      return _setup().then(function() {
        return _get("getRules", "" + config.apiUrl + "/rules");
      });
    };
    this.getRule = function(id) {
      return _setup().then(function() {
        return _get("getRule", "" + config.apiUrl + "/rules/" + id);
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
        return _post("createRule", "" + config.apiUrl + "/rules", body);
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
        if (config.debug) {
          console.log("Debug: updateRule body", body);
        }
        return _put("updateRule", "" + config.apiUrl + "/rules", body);
      });
    };
    this.deleteRule = function(id) {
      return _setup().then(function() {
        return _del("deleteRule", "" + config.apiUrl + "/rules/" + id);
      });
    };
    this.getSchedules = function() {
      return _setup().then(function() {
        return _get("getSchedules", "" + config.apiUrl + "/schedules");
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
        return _post("createSchedule", "" + config.apiUrl + "/schedules", body);
      });
    };
    this.getScheduleAttributes = function(id) {
      return _setup().then(function() {
        return _get("getScheduleAttributes", "" + config.apiUrl + "/schedules/" + id);
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
        return _put("setScheduleAttributes", "" + config.apiUrl + "/schedules/" + id, body);
      });
    };
    this.deleteSchedule = function(id) {
      return _setup().then(function() {
        return _del("deleteSchedule", "" + config.apiUrl + "/schedules/" + id);
      });
    };
    this.getScenes = function() {
      return _setup().then(function() {
        return _get("getScenes", "" + config.apiUrl + "/scenes");
      });
    };
    this.createScene = function(id, name, lights) {
      return _setup().then(function() {
        var body;
        body = {
          "name": name,
          "lights": lights
        };
        return _put("createScene", "" + config.apiUrl + "/scenes/" + id, body);
      });
    };
    this.updateScene = function(id, light, state) {
      return _setup().then(function() {
        return _put("updateScene", "" + config.apiUrl + "/scenes/" + id + "/lights/" + light + "/state", state);
      });
    };
    this.getSensors = function() {
      return _setup().then(function() {
        return _get("getSensors", "" + config.apiUrl + "/sensors");
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
        return _post("createSensor", "" + config.apiUrl + "/sensors", body);
      });
    };
    this.searchNewSensors = function() {
      return _setup().then(function() {
        return _post("searchNewSensors", "" + config.apiUrl + "/sensors", null);
      });
    };
    this.getNewSensors = function() {
      return _setup().then(function() {
        return _get("getNewSensors", "" + config.apiUrl + "/sensors/new");
      });
    };
    this.getSensor = function(id) {
      return _setup().then(function() {
        return _get("getSensor", "" + config.apiUrl + "/sensors/" + id);
      });
    };
    this.renameSensor = function(id, name) {
      return _setup().then(function() {
        var body;
        body = {
          "name": name
        };
        return _put("renameSensor", "" + config.apiUrl + "/sensors/" + id, body);
      });
    };
    this.updateSensor = function(id, config) {
      return _setup().then(function() {
        return _put("updateSensor", "" + config.apiUrl + "/sensors/" + id + "/config", config);
      });
    };
    this.setSensorState = function(id, state) {
      return _setup().then(function() {
        return _put("setSensorState", "" + config.apiUrl + "/sensors/" + id + "/state", state);
      });
    };
    this.getTimezones = function() {
      return _setup().then(function() {
        return _get("getTimezones", "" + config.apiUrl + "/info/timezones");
      });
    };
  }
]);
