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

    function forecastRequest(longitude = 999, latitude = 999, callback = null) {
        // Parameters:
        //  1. Longitude of location for which a forecast is required
        //  2. Latitude of location for which a forecast is required
        //  3. Optional synchronous operation callback
        // Returns:
        //  If callback is null, the function returns a table with key 'response'
        //  If callback is not null, the function returns nothing
        //  If there is an error, the function returns a table with key 'err'

		if (!checkCoords(longitude, latitude, "forecastRequest")) return {"err": "Co-ordinate error"};

        local url = FORECAST_URL + _apikey + "/" + format("%.6f", latitude) + "," + format("%.6f", longitude);
        local req = http.get(url);

        if (callback) {
        	req.sendasync(callback.bindenv(this));
        } else {
        	return req.sendsync();
		}
    }

    function timeMachineRequest(longitude = 999, latitude = 999, time = null, callback = null) {
        // Parameters:
        //  1. Longitude of location for which a forecast is required
        //  2. Latitude of location for which a forecast is required
        //  3. A Unix time or ISO 1601-formatted string
        //  4. Optional synchronous operation callback
        // Returns:
        //  If callback is null, the function returns a table with key 'response'
        //  If callback is not null, the function returns nothing
        //  If there is an error, the function returns a table with key 'err'

		if (!checkCoords(longitude, latitude, "timeMachineRequest")) return {"err": "Co-ordinate error"};

		if (time == null || time.len() == 0) {
			if (_debug) server.error("Forecastio.timeRequest() requires a valid time parameter");
			return {"err": "Timestamp error"};
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

        local url = FORECAST_URL + _apikey + "/" + format("%.6f", latitude) + "," + format("%.6f", longitude) + "," + timeString;
        local req = http.get(url);

        if (callback) {
        	req.sendasync(callback.bindenv(this));
        } else {
        	return req.sendsync();
		}
    }

    // ********** PRIVATE FUNCTIONS - DO NOT CALL **********

    function checkCoords(longitude, latitude, caller) {

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
