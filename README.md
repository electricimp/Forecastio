# Forecastio

This class provides access to the Forecast API (v2) provided by [Forecast.io](http://forecast.io/).

Access to the API is controlled by key. To obtain a key, please register for developer access [here](https://developer.forecast.io/register).

Please note that the Forecast API is a commercial service. Though the first 1000 API calls made under your API key are free of charge, subsequent calls are billed at a rate of $0.0001 per call. The usage terms also require the addition of a “Powered by Forecast” badge that links to `http://forecast.io/` wherever data from the API is displayed.

**To add this library to your project, add** `#require "Forecastio.class.nut:1.0.0"` **to the top of your agent code**

## Class Usage

### Constructor: Forecastio(*apiKey[, debug]*)

The constructor requires your Forecast API key as a string.

You may also pass a boolean value into the *debug* parameter: if you pass `true`, extra debugging information will be posted to the device log. This is disabled by default.

```squirrel
#require "Forecastio.class.nut:1.0.0"

const API_KEY = "<YOUR_FORECAST_API_KEY>";

fc <- Forecastio(YOUR_FORECAST_API_KEY);
```

## Class Methods

### forecastRequest(*longitude, latitude[, callback]*)

This method sends a [forecast request](https://developer.forecast.io/docs/v2#forecast_call) to the Forecast API using the co-ordinates passed into the parameters *longitude* and *latitude*.

You can pass an optional callback function: if you do, the forecast request will be made asynchronously and the callback executed with the returned data. Your callback function requires a single parameter into which a the response will be passed as a table, *response*, containing the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *statuscode*   | Integer | HTTP status code (or libcurl error code) |
| *headers*      | Table   | Squirrel table of returned HTTP headers |
| *body*         | String  | Returned HTTP body (if any) |

&nbsp;<br>If the request is made asynchronously, *forecastRequest()* does not return anything.

If you choose not to provide a callback, the forecast will be made synchronously (blocking) and the *response* table will be returned by *forecastRequest()*.

Should an error occur during the assembly and sending of the request, the function will return a table with the key *err* whose value is a human-readable error message. The key *err* is not present if no error has been encountered.

The data returned by the Forecast API is complex and is not parsed in any way by the library. To convert the returned JSON data into a Squirrel-accessible table, used `http.jsondecode(response.body);`. This is typically wrapped in a `try... catch` structure in order to trap decode errors.

#### Example

```squirrel
fc.forecastRequest(myLongitude, myLatitude, function(response) {
	local forecast = null;
	if (debug) server.log("Weather forecast data received from forecast.io");

    // Decode the JSON-format data from forecast.io (error thrown if invalid)
    try {
        forecast = http.jsondecode(response.body);

        if ("hourly" in forecast) {
            if ("data" in forecast.hourly) {
                // Get second item in array: this is the weather one hour from now
                local item = forecast.hourly.data[1];
                local data = {};
                data.icon <- item.icon;
                data.temp <- item.apparentTemperature;
                device.send("show.weather.forecast", data);

                // Log the outlook
                local celsius = ((data.temp.tofloat() - 32.0) * 5.0) / 9.0;
                local message = "Outlook: " + data.cast + ". Temperature: " + format("%.1f", celsius) + "ºC";
                server.log(message);
            }
        }
    } catch(error) {
        if (debug) {
            server.error("Could not decode JSON returned by Forecast.io");
            server.error(error);
        }
    }
});
```

### timeMachineRequest(*longitude, latitude, time[, callback]*)

This method sends a [time machine request](https://developer.forecast.io/docs/v2#time_call) to the Forecast API using the co-ordinates passed into the parameters *longitude* and *latitude*, and a timestamp. The value passed into the parameter *time* should be either a Unix timestamp (an Integer) or a string formatted according to [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601).

You can pass an optional callback function: if you do, the forecast request will be made asynchronously and the callback executed with the returned data. Your callback function requires a single parameter into which a the response will be passed as a table, *response*, containing the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *statuscode*   | Integer | HTTP status code (or libcurl error code) |
| *headers*      | Table   | Squirrel table of returned HTTP headers |
| *body*         | String  | Returned HTTP body (if any) |

&nbsp;<br>If the request is made asynchronously, *timeMachineRequest()* does not return anything.

If you choose not to provide a callback, the forecast will be made synchronously (blocking) and the *response* table will be returned by *timeMachineRequest()*.

Should an error occur during the assembly and sending of the request, the function will return a table with the key *err* whose value is a human-readable error message. The key *err* is not present if no error has been encountered.

The data returned by the Forecast API is complex and is not parsed in any way by the library. To convert the returned JSON data into a Squirrel-accessible table, used `http.jsondecode(response.body);`. This is typically wrapped in a `try... catch` structure in order to trap decode errors.

## License

This class is licensed under the [MIT License](https://github.com/electricimp/Forecastio/blob/master/LICENSE)
