Title: Web APIs design: an improvable example
Date: 2013-10-29 01:00
Category: design
Tags:  API, design, HTTP, JSON, OpenWeatherMap, pyowm
Slug: web-apis-design-an-improvable-example
Authors: csparpa
Summary: Digression on the Open Weather Map web API and ways to improve its design

Today I want to speak about the [OWM web API 2.5](http://bugs.openweathermap.org/projects/api/wiki/API_2_5) and its design. As this API follows a versioning scheme, this analysis holds for version 2.5 (which then I suppose is not changing in time!)
 
First let me clearly state that I'm writing this post as a "gathering of thoughts” I've had during the first draft development of the PyOWM library, and it is not meant to be a negative criticism – but rather a positive review – to the  API architects/developers. I just want to write here my ideas so that the OWM API can be improved in future versions – and I will commit myself to help with this process, if needed.  
 
I found this activity also very educational because it made me think again to all that books and articles I've read on the Internet about API design and – good grief – they were damn right!  

As I said, developing the PyOWM library I had to write code interfacing with the OWM web API, which basically meant I had to setup an HTTP client and some kind of parsing module in order to read the API's responses, squeeze useful data out of them and inject data into my custom object model to the benefit of users. These funny tasks lead me, nevertheless, to crash onto a few improvable API design features that made my work unreasonably more complicated and error-prone. And a bug also came into sight.  
 
Be warned: this is a quite long post ;-)  

### Design oddities

I found the following ones:

1. mismatch between endpoint naming and features that endpoints implement
2. inconsistent formatting of JSON data returned by different endpoints when queried for the same (or similar) data entities
3. lack of use of proper status codes in HTTP headers for error signaling
4. certain endpoints map on 200 (Ok) HTTP status codes also 404 (Not Found) error conditions
  
And there is something more… I won't blame anybody  of these, but they really should be taken into account:
  
- the API is poorly documented
- the API is not RESTful
  
Let's dig into each point.  

### Endpoints: naming vs features

The API lets you basically retrieve different weather datasets (observations, forecasts, historic data) about places in the world.
The most simple and natural feature for the API is to let you query for the currently observed weather in a location: this can be specified in a twofold manner, either by passing the API a toponym or a lat/lon couple.  

The related endpoints are:  

```text
#Feature: retrieve current weather - location is specified via toponym
http://api.openweathermap.org/data/2.5/weather?q=London,uk

#Feature: retrieve current weather - location is specified via lat/lon
http://api.openweathermap.org/data/2.5/weather?lat=57&lon=-2.15
```

Here the naming seems to quite proper with regards to the implemented feature: great!  
 
Things worsen when you consider these API features: find the current weather conditions in all the locations having certain characteristics, such as having toponyms that are similar/equal to a given string or being in the neighborhood of a given lat/lon couple.  
Here are the related endpoints:  

```text
#Feature: retrieve current weathers in all the locations whose names exactly equal to the string "London"
http://api.openweathermap.org/data/2.5/find?q=London&type=accurate

#Feature: retrieve current weathers in all the locations whose names contains the string "London"
http://api.openweathermap.org/data/2.5/find?q=London&type=like

#Feature: retrieve current weathers in all the locations in the neighborhoods of a lat/lon couple
http://api.openweathermap.org/data/2.5/find?lat=57&lon=-2.15
```

Now, this lays down three questions:  

1. what the heck does "neighborhood” mean? The API documentation is silent about this topic. One could suppose that the API is performing a geographic search based on a circle with center into the specified lat/lon couple and a certain radius – and this is effectively what has been done in a prior (and now dismissed) version of the API. But nobody knows if this guess is true and – above all – what is the value for the radius , as it cannot be specified by the user.
2. we know for sure that behind the API a geocoder is in action (for those who don't know what a geocoder is: it is a SW module that performs direct mapping between geographic labels – such as addresses, city names, toponyms into a geographic coordinates couple or even a geographic feature on a map. Sometimes geocoders also perform the reverse mapping): for this reason, we have a "smell” here… the "find” endpoint is implementing a geocoder-like feature: it should not be responsibility of the API to behave like that, or at least, if this responsibility is implemented it should be kept separate from the weather data provisioning. So, in my opinion, there should be an endpoint providing geocoding queries and another one providing current weather data on a single location: then, queries for current weather data on X multiple locations can be done with X API requests for current weather on a each single location. You think that users won't do that? Yes, they shouldn't: an automatic HTTP client should. Indeed, that's what APIs are meant to do: automatize :-)
3. isn't the "accurate” parameter unnecessary? A "like” query should also give as results literal word matchings!

Another feature: retrieve weather forecasts for a location. You can get forecasts for every 3-hours of the next 5 days or for every of the next 14 days.  

Here are the endpoints:

```text
#Feature: retrieve 3h weather forecast for a location
http://api.openweathermap.org/data/2.5/forecast?q=London

#Feature: retrieve daily weather forecast for a location
http://api.openweathermap.org/data/2.5/forecast/daily?q=London
```

Again, questions:

1. good naming here, but it can be improved. I would use "/forecast/daily” for daily forecast and "/forecast/3h” for 3-hours forecast. A viable alternative could be using a single endpoint "/forecast” along with a "interval=[daily|3h]” query parameter.
2. only results coming from the daily forecast query can be paged by the user: the user can control how many results are returned by the API through an optional parameter named "cnt”. This is not possible with regards to the 3-hours forecast query: why?
3. why isn't it possible to specify a forecast through a lon/lat couple? Maybe it is a design decision, but it creates asimmetry with the previously described API features.
4. why isn't it possible to query for weather forecasts for all the locations having name similar to a given string or being in the neighborhood of a specific lon/lat couple? Guess it's due to API designers laziness…


### Same conceptual entities, different JSON representations

Clients of data API expect returned data to be structured using some kind of language or convention and  they also expect that structured data is organized in chunks or logical groups  that clearly convey cohesion and hierarchy. In our specific case, the description language used by the API can either be JSON or XML (but we will only rely on JSON from now on): this is a consolidated practice among the web APIs  and this sounds good. At this point, we want to inspect the JSON returned by a query for current weather data on London,UK:  

```text
#Payload of response to request:
#GET http://api.openweathermap.org/data/2.5/weather?q=London,uk
{
  "coord": {
     "lon": -0.12574,
     "lat": 51.50853 },
  "sys": {
     "country": "GB",
     "sunrise": 1378877413,
     "sunset": 1378923812 },
  "weather": [{
     "id": 521,
     "main": "Rain",
     "description": "proximity shower rain",
     "icon": "09d" }],
  "base": "gdps stations",
  "main": {
       "temp": 288.88,
       "pressure": 1021,
       "humidity": 63,
       "temp_min": 287.15,
       "temp_max": 290.37 },
  "wind": {
       "speed": 4.6,
       "deg": 330 },
  "clouds": {
       "all": 75 },
  "dt": 1378899070,
  "id": 2643743,
  "name": "London",
  "cod": 200
}
```

The "coord”, "country”, "id” and "name” JSON root elements refer to a single logical entity: the location for which the current weather is given (London, UK). Can you see it? Wouldn't have it been better to group all the location info into a single JSON element? For example, like this:  

```text
{
...
"location":
{
  "coord": {
     "lon": -0.12574,
     "lat": 51.50853 },
  "country": "GB",
  "name": "London",
  "id": 2643743
}
 ...
}
```

Another legitimate question is: why location information spread out from the data regarding current weather? Here the API is clearly returning more data than it has been asked for. But what is really obscure is that location info are structured in different ways if returned by different endpoints. In example, if we ask for the daily weather forecast on London,UK we get:  

```text
#Payload of response to request:
#GET http://api.openweathermap.org/data/2.5/forecast/daily?q=London
{
"city" : {
  "coord" : {
     "lat" : 51.50853,
     "lon" : -0.12573999999999999 },
   "country" : "GB",
   "id" : 2643743,
   "name" : "London",
   "population" : 1000000},
...
}
```

Now data is structured! Magic? No: an evil art! And it drives me – and everyone else who is developing  a client library for this API – literally mad to parse the JSON: each endpoint, in practice, needs a specific JSON parser in order to parse the same data entities, and this introduces complexity into the code. Had the data been structured uniformly across the different endpoints, just one parser would be needed.  

### HTTP status codes are neglected

This is one of the main shortcomings of this API: it does not convey error conditions through a proper use of HTTP status codes. The API users want to receive a 200 (OK) status code in the HTTP response's header – along with data – whenever a GET request is a hit: this means that the endpoint exists and is correctly invoked by the clients; the same way, users want to receive a 4xx or 5xx status code whenever something goes wrong with their request: this can happen for several reasons, either due to clients or the server itself. But, to be short: a user expects a non-200 status code to be returned whenever something goes wrong with its request.  s

The OWM API **always returns a 200 HTTP status code**, no matter what happens. But, if something goes wrong with a client's request, it returns the right HTTP status code and an explanation message into the HTTP response's payload! An example: we want to query for current weather on a non-existent location (the folkloristic: "sev082hfrv2qvf2vunr”)  

```text
#HTTP request
GET /data/2.5/weather?q=sev082hfrv2qvf2vunr HTTP/1.1
#HTTP response headers
HTTP/1.1 200 OK
Server: nginx
Content-Type: application/json; charset=utf-8
...
#HTTP response payload
{"message":"Error: Not found city","cod":"404"}
```

The JSON payload is clear: the location has not been found and a 404 (Not Found) error code has been returned. However the code is returned **into the payload**, so the clients have to first presume that the request was a success, then parse the payload and find out that it wasn't! The API is mis-using the HTTP protocol, which is a very nasty behaviour for clients and *blows the API away from RESTfulness*, as well.  

### "Not found” is different from "Found but no data available”

The improper usage of HTTP status codes is particularly problematic in the case of queries to historic weather data registred by meteostations. A meteostation is identified by a unique integer number and when historic data is queried, the API returns a JSON list of data measurements for the desired meteostation. So, an empty list means: no data for the desired meteostation. Now, if I want to get historic data for a station that is not present in the API's meteostations collection (like, say, station number -2147483648), I get:  

```text
#HTTP request
GET /data/2.5/history/station?id=-2147483648&type=tick HTTP/1.1
#HTTP response headers
HTTP/1.1 200 OK
Server: nginx
Content-Type: application/json; charset=utf-8
...
#HTTP response payload
{
"message":"",
"cod":"200",
"type":"tick",
"station_id":-2147483648,
"calctime":" tick = 0.294 total=0.2954",
"cnt":0,
"list":[]
}
```

Again, a 200 status code (that means: "Ok, everything went smoothly”) and – surprisingly – an empty data list. What I would have expected is a 404 HTTP status code, telling me: "Hey, this station is not listed in my meteostations database”! So in this case, an error condition is wrongly mapped onto a non-error condition. And what if I query for an existing meteostation and it has no data available? How can I discern the "not found” case from the "found but no data available” case?