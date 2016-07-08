# Forecastio

This class provides access to the Forecast API (v2) provided by [Forecast.io](http://forecast.io/).

Access to the API is controlled by key. To obtain a key, please register for developer access [here](https://developer.forecast.io/register).

Please note that the Forecast API is a commercial service. Though the first 1000 API calls made under your API key are free of charge, subsequent calls are billed at a rate of $0.0001 per call. The usage terms also require the addition of a “Powered by Forecast” badge that links to `http://forecast.io/` wherever data from the API is displayed.

**To add this library to your project, add** `#require "Forecastio.class.nut:1.0.0"` **to the top of your agent code**

## Class Usage

### Constructor: Forecastio(*apiKey[, debug]*)

The constructor requires your Forecast API key as a string.

You may also pass a boolean value into the *debug* parameter: if you pass `true`, extra debugging information will be posted to the device log. This is disabled by default.

## License

This class is licensed under the [MIT License](https://github.com/electricimp/Forecastio/blob/master/LICENSE)
