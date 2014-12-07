angular.module("hue", []).service("hue", [
  "$http", "$q", function($http, $q) {
    var apiUrl, bridgeIP, debug, getBridgeNupnp, isReady, setup, username, _del, _get, _post, _put, _responseHandler;
    username = "newdeveloper";
    apiUrl = "";
    bridgeIP = "";
    isReady = false;
    debug = true;
    setup = function() {
      var deferred;
      deferred = $q.defer();
      if (isReady) {
        deferred.resolve();
      } else {
        getBridgeNupnp().then(function(data) {
          bridgeIP = data[0].internalipaddress;
          apiUrl = "http://" + bridgeIP + "/api/" + username;
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
        if (debug) {
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
        if (debug) {
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
        if (debug) {
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
        if (debug) {
          console.log("Error: " + name, response);
        }
        return deferred.reject;
      });
      return deferred.promise;
    };
    _responseHandler = function(name, response, deferred) {
      if ((response[0] != null) && response[0].error) {
        if (debug) {
          console.log("Error: " + name, response);
        }
        return deferred.reject;
      } else {
        if (debug) {
          console.log("Debug: " + name, response);
        }
        return deferred.resolve(response);
      }
    };
    getBridgeNupnp = function() {
      return _get("getBridgeNupnp", "https://www.meethue.com/api/nupnp");
    };
    this.getBridgeIP = function() {
      return setup().then(function() {
        return bridgeIP;
      });
    };
    this.getLights = function() {
      return setup().then(function() {
        return _get("getLights", "" + apiUrl + "/lights");
      });
    };
    this.getNewLights = function() {
      return setup().then(function() {
        return _get("getNewLights", "" + apiUrl + "/lights/new");
      });
    };
    this.searchNewLights = function() {
      return setup().then(function() {
        return _post("searchNewLights", "" + apiUrl + "/lights", {});
      });
    };
    this.getLight = function(id) {
      return setup().then(function() {
        return _get("getLight", "" + apiUrl + "/lights/" + id);
      });
    };
    this.setLightName = function(id, name) {
      return setup().then(function() {
        var body;
        body = {
          "name": name
        };
        return _put("setLightName", "" + apiUrl + "/lights/" + id, body);
      });
    };
    this.setLightState = function(id, state) {
      return setup().then(function() {
        return _put("setLightState", "" + apiUrl + "/lights/" + id + "/state", state);
      });
    };
    this.getConfiguration = function() {
      return setup().then(function() {
        return _get("getConfiguration", "" + apiUrl + "/config");
      });
    };
    this.setConfiguration = function(configuration) {
      return setup().then(function() {
        return _put("setConfiguration", "" + apiUrl + "/config", configuration);
      });
    };
    this.createUser = function(devicetype, username) {
      if (username == null) {
        username = false;
      }
      return setup().then(function() {
        var user;
        user = {
          "devicetype": devicetype
        };
        if (username) {
          user.username = username;
        }
        return _post("createUser", "http://" + bridgeIP + "/api", user);
      });
    };
    this.deleteUser = function(username) {
      return setup().then(function() {
        return _del("deleteUser", "" + apiUrl + "/config/whitelist/" + username);
      });
    };
    this.getFullState = function() {
      return setup().then(function() {
        return _get("getFullState", apiUrl);
      });
    };
    this.getGroups = function() {
      return setup().then(function() {
        return _get("getGroups", "" + apiUrl + "/groups");
      });
    };
    this.createGroup = function(name, lights) {
      return setup().then(function() {
        var body;
        body = {
          "lights": lights,
          "name": name
        };
        if (debug) {
          console.log("Debug: createGroup body", body);
        }
        return _post("createGroup", "" + apiUrl + "/groups", body);
      });
    };
    this.getGroupAttributes = function(id) {
      return setup().then(function() {
        return _get("getGroupAttributes", "" + apiUrl + "/groups/" + id);
      });
    };
    this.setGroupAttributes = function(id, name, lights) {
      return setup().then(function() {
        var body;
        body = {
          "lights": lights,
          "name": name
        };
        return _put("setGroupAttributes", "" + apiUrl + "/groups/" + id, body);
      });
    };
    this.setGroupState = function(id, state) {
      return setup().then(function() {
        return _put("setGroupState", "" + apiUrl + "/groups/" + id + "/action", state);
      });
    };
    this.deleteGroup = function(id) {
      return setup().then(function() {
        return _del("deleteUser", "" + apiUrl + "/groups/" + id);
      });
    };
    this.getRules = function() {
      return setup().then(function() {
        return _get("getRules", "" + apiUrl + "/rules");
      });
    };
    this.getRule = function(id) {
      return setup().then(function() {
        return _get("getRule", "" + apiUrl + "/rules/" + id);
      });
    };
    this.createRule = function(name, conditions, actions) {
      return setup().then(function() {
        var body;
        body = {
          "name": name,
          "conditions": conditions,
          "actions": actions
        };
        return _post("createRule", "" + apiUrl + "/rules", body);
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
      return setup().then(function() {
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
        if (debug) {
          console.log("Debug: updateRule body", body);
        }
        return _put("updateRule", "" + apiUrl + "/rules", body);
      });
    };
    this.deleteRule = function(id) {
      return setup().then(function() {
        return _del("deleteRule", "" + apiUrl + "/rules/" + id);
      });
    };
    this.getSchedules = function() {
      return setup().then(function() {
        return _get("getSchedules", "" + apiUrl + "/schedules");
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
      return setup().then(function() {
        var body;
        body = {
          "name": name,
          "description": description,
          "command": command,
          "time": time,
          "status": status,
          "autodelete": autodelete
        };
        return _post("createSchedule", "" + apiUrl + "/schedules", body);
      });
    };
    this.getScheduleAttributes = function(id) {
      return setup().then(function() {
        return _get("getScheduleAttributes", "" + apiUrl + "/schedules/" + id);
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
      return setup().then(function() {
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
        return _put("setScheduleAttributes", "" + apiUrl + "/schedules/" + id, body);
      });
    };
    this.deleteSchedule = function(id) {
      return setup().then(function() {
        return _del("deleteSchedule", "" + apiUrl + "/schedules/" + id);
      });
    };
    this.getScenes = function() {
      return setup().then(function() {
        return _get("getScenes", "" + apiUrl + "/scenes");
      });
    };
    this.createScene = function(id, name, lights) {
      return setup().then(function() {
        var body;
        body = {
          "name": name,
          "lights": lights
        };
        return _put("createScene", "" + apiUrl + "/scenes/" + id, body);
      });
    };
    this.updateScene = function(id, light, state) {
      return setup().then(function() {
        return _put("updateScene", "" + apiUrl + "/scenes/" + id + "/lights/" + light + "/state", state);
      });
    };
    this.getSensors = function() {
      return setup().then(function() {
        return _get("getSensors", "" + apiUrl + "/sensors");
      });
    };
    this.createSensor = function(name, modelid, swversion, type, uniqueid, manufacturername, state, config) {
      if (state == null) {
        state = null;
      }
      if (config == null) {
        config = null;
      }
      return setup().then(function() {
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
        return _post("createSensor", "" + apiUrl + "/sensors", body);
      });
    };
    this.searchNewSensors = function() {
      return setup().then(function() {
        return _post("searchNewSensors", "" + apiUrl + "/sensors", null);
      });
    };
    this.getNewSensors = function() {
      return setup().then(function() {
        return _get("getNewSensors", "" + apiUrl + "/sensors/new");
      });
    };
    this.getSensor = function(id) {
      return setup().then(function() {
        return _get("getSensor", "" + apiUrl + "/sensors/" + id);
      });
    };
    this.renameSensor = function(id, name) {
      return setup().then(function() {
        var body;
        body = {
          "name": name
        };
        return _put("renameSensor", "" + apiUrl + "/sensors/" + id, body);
      });
    };
    this.updateSensor = function(id, config) {
      return setup().then(function() {
        return _put("updateSensor", "" + apiUrl + "/sensors/" + id + "/config", config);
      });
    };
    this.setSensorState = function(id, state) {
      return setup().then(function() {
        return _put("setSensorState", "" + apiUrl + "/sensors/" + id + "/state", state);
      });
    };
    this.getTimezones = function() {
      return setup().then(function() {
        return _get("getTimezones", "" + apiUrl + "/info/timezones");
      });
    };
  }
]);
