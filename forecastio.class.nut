class Forecastio {

    // This class allows you to make one of two possible calls to Forecast.io’s
    // Forecast API (v2), ie. forecast requests and time-machine requests. For
    // more information, see https://developer.forecast.io/docs/v2
    // Access to the API is controlled by key. Register for developer access
    // here: https://developer.forecast.io/register

    // Note: this class does not parse the incoming data, which is highly complex.
    // It is up to your application to extract the data you require

    // Written by Tony Smith (@smittytone)
    // Copyright Electric Imp, Inc. 2016
    // License: MIT

    static FORECAST_URL = "https://api.forecast.io/forecast/";
    static VERSION = [1,0,0];
    static VALID_UNITS = [us,si,ca,uk2,auto];

    _apikey = null;
    _debug = false;

    constructor (key = null, debug = false) {
        if (imp.environment() != ENVIRONMENT_AGENT) {
            server.error("Forecast.io class must be instantiated by the agent");
            return null;
        }

        if (key == "" || key = null) {
            server.error("Forecast.io requires an API key");
            return null;
        }

        _debug = debug;
        _apikey = key;
    }

    function forecastRequest(longitude = 999, latitude = 999, units = us, callback = null) {
        // Parameters:
        //  1. Longitude of location for which a forecast is required
        //  2. Latitude of location for which a forecast is required
        //  3. Units parameter which defaults to us if improperly specified
        //  4. Optional synchronous operation callback
        // Returns:
        //  If callback is null, the function returns a table with key 'response'
        //  If callback is not null, the function returns nothing
        //  If there is an error, the function returns a table with key 'err'

        if (!_checkCoords(longitude, latitude, "forecastRequest")) {
            if (callback) {
                callback("Co-ordinate error", null);
                return null;
            } else {
                return {"err": "Co-ordinate error"};
            }
        }
        
        if (!(units in VALID_UNITS)) {
            units = us;
        }
        
        local url = FORECAST_URL + _apikey + "/" + format("%.6f", latitude) + "," + format("%.6f", longitude) + "?units=" + units;
        return _sendRequest(http.get(url), callback);
    }

    function timeMachineRequest(longitude = 999, latitude = 999, time = null, units = us, callback = null) {
        // Parameters:
        //  1. Longitude of location for which a forecast is required
        //  2. Latitude of location for which a forecast is required
        //  3. A Unix time or ISO 1601-formatted string
        //  4. Units parameter which defaults to us if improperly specified
        //  5. Optional synchronous operation callback
        // Returns:
        //  If callback is null, the function returns a table with key 'response'
        //  If callback is not null, the function returns nothing
        //  If there is an error, the function returns a table with key 'err'

        if (!_checkCoords(longitude, latitude, "timeMachineRequest")) {
            if (callback) {
                callback("Co-ordinate error", null);
                return null;
            } else {
                return {"err": "Co-ordinate error"};
            }
        }

        if (time == null || time.tostring().len() == 0) {
            if (_debug) server.error("Forecastio.timeRequest() requires a valid time parameter");
            return {"err": "Timestamp error"};
        }

        if (!(units in VALID_UNITS)) {
            units = us;
        }
        
        local timeString;
        if (typeof time == "integer") {
            timeString = time.tostring();
        } else if (typeof time == "string") {
            timeString = time;
        } else {
            if (_debug) server.error("Forecastio.timeRequest() requires a valid time parameter");
            return {"err": "Timestamp error"};
        }

        local url = FORECAST_URL + _apikey + "/" + format("%.6f", latitude) + "," + format("%.6f", longitude) + "," + timeString + "?units=" + units;
        return _sendRequest(http.get(url), callback);
    }

    // ********** PRIVATE FUNCTIONS - DO NOT CALL **********

    function _sendRequest(req, cb) {
        if (cb) {
            req.sendasync(function(resp) {
                local err, data, count;
                if (resp.statuscode != 200) {
                    err = format("Unable to retrieve forecast data (code: %i)", resp.statuscode);
                } else {
                    try {
                        data = http.jsondecode(resp.body);
                    } catch(exp) {
                        err = "Unable to decode data received from Forecast.io: " + exp;
                    }
                }

                // Add daily API request count to 'data'
                count = _getCallCount(resp);
                if (count != -1) data.callCount <- count;

                cb(err, data);
            }.bindenv(this));
            return null;
        } else {
            local resp = req.sendsync();
            local err, data, count, returnTable;
            if (resp.statuscode != 200) {
                err = format("Unable to retrieve forecast data (code: %i)", response.statuscode);
            } else {
                try {
                    data = http.jsondecode(response.body);
                } catch(exp) {
                    err = "Unable to decode data received from Forecast.io: " + exp;
                }
            }

            // Add daily API request count to 'data'
            count = _getCallCount(resp);
            if (count != -1) data.callCount <- count;

            // Create table of returned data
            returnTable.err <- err;
            returnTable.data <- data;

            return returnTable;
        }
    }

    function _getCallCount(resp) {
        // Extract daily API request count from Forecast.io response header
        if ("headers" in resp) {
            if ("x-forecast-api-calls" in resp.headers) {
                local a = resp.headers["x-forecast-api-calls"];
                return a.tointeger();
            }
        }

        return -1;
    }

    function _checkCoords(longitude, latitude, caller) {
        // Check that valid co-ords have been supplied
        if (longitude == 999 || latitude == 999) {
            if (_debug) server.error("Forecastio." + caller + "() requires valid latitude/longitude co-ordinates");
            return false;
        }

        if (latitude > 90 || latitude < -90) {
            if (_debug) server.error("Forecastio." + caller + "() requires valid a latitude co-ordinate");
            return false;
        }

        if (longitude > 180 || longitude < -180) {
            if (_debug) server.error("Forecastio." + caller + "() requires valid a latitude co-ordinate");
            return false;
        }

        return true;
    }
}
