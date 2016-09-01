# Forecastio 1.1.2

This class provides access to the Forecast API (v2) provided by [Forecast.io](http://forecast.io/).

Access to the API is controlled by key. To obtain a key, please register for developer access [here](https://developer.forecast.io/register).

The Forecast API returns a wealth of data (in JSON format). As such, it is left to your application to decode the returned data as only you know which data your application requires. You can view the many fields the returned data may contain [here](https://developer.forecast.io/docs/v2).

Please note that the Forecast API is a commercial service. Though the first 1000 API calls made under your API key are free of charge, subsequent calls are billed at a rate of $0.0001 per call. You and your application will not be notified by the library if this occurs, so you may wish to add suitable call-counting code to your application. The usage terms also require the addition of a “Powered by Forecast” badge that links to `http://forecast.io/` wherever data from the API is displayed.

**To add this library to your project, add** `#require "Forecastio.class.nut:1.1.2"` **to the top of your agent code**

## Class Usage

### Constructor: Forecastio(*apiKey[, debug]*)

The constructor requires your Forecast API key as a string.

You may also pass a boolean value into the *debug* parameter: if you pass `true`, extra debugging information will be posted to the device log. This is disabled by default.

```squirrel
#require "Forecastio.class.nut:1.1.2"

const API_KEY = "<YOUR_FORECAST_API_KEY>";

fc <- Forecastio(API_KEY);
```

## Class Methods

### forecastRequest(*longitude, latitude[, callback]*)

This method sends a [forecast request](https://developer.forecast.io/docs/v2#forecast_call) to the Forecast API using the co-ordinates passed into the parameters *longitude* and *latitude* as integers, floats or strings.

You can pass an optional callback function: if you do, the forecast request will be made asynchronously and the callback executed with the returned data. Your callback function must include two parameters: *err*, into which a human-readable error message error message will passed if an error was encountered during the assembly or sending of the request; and *data*, a table containing the decoded response from Forecast.io.

If you choose not to provide a callback, the forecast will be made synchronously (blocking) and a table containing *err* and *data*, as above, will be returned by *forecastRequest()*. If the request is made asynchronously, *forecastRequest()* does not return anything.

The data returned by the Forecast API is complex and is not parsed in any way by the library. However, *data* contains an additional key, *callCount*, which is the number of calls you have made to the Forecast API. This is decoded by the library and added to the returned data table.

#### Example

```squirrel
fc.forecastRequest(myLongitude, myLatitude, function(err, data) {
    if (err) server.error(err);

    if (data) {
        server.log("Weather forecast data received from forecast.io");
        if ("hourly" in data) {
            if ("data" in data.hourly) {
                // Get second item in array: this is the weather one hour from now
                local item = data.hourly.data[1];
                local sendData = {};
                sendData.cast <- item.icon;
                sendData.temp <- item.apparentTemperature;
                device.send("weather.show.forecast", sendData);

                // Log the output
                local celsius = ((sendData.temp.tofloat() - 32.0) * 5.0) / 9.0;
                local message = "Outlook: " + sendData.cast + ". Temperature: " + format("%.1f", celsius) + "ºC";
                server.log(message);
            }
        }

        if ("callCount" in data) server.log("Current Forecast API call tally: " + data.callCount + "/1000");
    }
});
```

### timeMachineRequest(*longitude, latitude, time[, callback]*)

This method sends a [time machine request](https://developer.forecast.io/docs/v2#time_call) to the Forecast API using the co-ordinates passed into the parameters *longitude* and *latitude*, and a timestamp. The value passed into the parameter *time* should be either a Unix timestamp (an Integer) or a string formatted according to [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601).

You can pass an optional callback function: if you do, the forecast request will be made asynchronously and the callback executed with the returned data. Your callback function must include two parameters: *err*, into which a human-readable error message error message will passed if an error was encountered during the assembly or sending of the request; and *data*, a table containing the decoded response from Forecast.io.

If you choose not to provide a callback, the forecast will be made synchronously (blocking) and a table containing *err* and *data*, as above, will be returned by *timeMachineRequest()*. If the request is made asynchronously, *timeMachineRequest()* does not return anything.

The data returned by the Forecast API is complex and is not parsed in any way by the library. However, *data* contains an additional key, *callCount*, which is the number of calls you have made to the Forecast API. This is decoded by the library and added to the returned data table.

#### Example

```squirrel
local monthAgo = time() - 2592000;
fc.timeMachineRequest(myLongitude, myLatitude, monthAgo, function(err, data) {
    if (err) server.error(err);

    if (data) {
        server.log("Weather forecast data received from forecast.io");
        if ("hourly" in data) {
            if ("data" in data.hourly) {
                local item = data.hourly.data[0];
                local sendData = {};
                sendData.cast <- item.icon;
                sendData.temp <- item.apparentTemperature;
                device.send("weather.show.forecast", sendData);

                // Log the output
                local celsius = ((sendData.temp.tofloat() - 32.0) * 5.0) / 9.0;
                local message = "Outlook: " + sendData.cast + ". Temperature: " + format("%.1f", celsius) + "ºC";
                server.log(message);
            }
        }

        if ("callCount" in data) server.log("Current Forecast API call tally: " + data.callCount + "/1000");
    }
});
```

### setUnits(*units*)

This methods allows you to specify the category of units in which the Forecast API will return data to your code. Pass into *units* one of the following strings: `"us"`, `"si"`, `"ca"`, `"uk"` or `"uk2"`, or `"auto"`. The default is `"auto"`, which selects the most appropriate units based on your location co-ordinates. Please see the Forecast API documentation for the [meaning of each setting](https://developer.forecast.io/docs/v2#options).

**Note** `"uk"` and `"uk2"` are identical; Forecast.io only supports the latter, but the former is included for the convenience of British coders.

This method returns the *Forecastio* instance, allowing you to chain *setUnits()* with *setLanguage()*, below:

#### Example

```squirrel
// Select data in SI units, and weather summaries in German
fc.setUnits("si").setLanguage("de");
```

### setLanguage(*language*)

This methods allows you to specify the language in which summaries of weather conditions are returned by the Forecast API. Pass into *language* a string indicating which language you require. The default is English, `"en"`. Please see the Forecast API documentation for the [full list of supported languages](https://developer.forecast.io/docs/v2#options).

This method returns the *Forecastio* instance.

See *setUnits()*, above, for an example of *setLanguage()*’s use.

## Release Notes

- 1.1.0 - Add Forecast API units and language support.
- 1.1.1 - Add Forecast API units’ ‘auto’ option and set as default.
- 1.1.2 - Allow longitude and latitude values to be passed in a strings; improve value verification.

## License

This class is licensed under the [MIT License](https://github.com/electricimp/Forecastio/blob/master/LICENSE)
