# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# short google maps
gm = google.maps

# global variable
root = exports ? this
root.infowindow = new gm.InfoWindow({width: 200 })
root.markersArray = []
root.circlesArray = []

# initialize function for google maps
initialize = ->
  mapOptions =
    center: new gm.LatLng(59.9401975, 30.0906896)
    zoom: 10
    mapTypeId: gm.MapTypeId.ROADMAP

  root.map = new gm.Map($("#map_canvas")[0],
    mapOptions)

  # add marker listener
  gm.event.addListener root.map, "click", (event) ->
    marker = createMarker(event.latLng, "name",
      '<div><br /><a href="#">Delete</a></div>')

# create the marker, geocode result and create circle
createMarker = (latlng, name, html) ->
  deleteOverlays()

  marker = new gm.Marker(
    position: latlng
    map: root.map
    draggable: true
  )
  # add marker to array
  root.markersArray.push marker

  # request to geocode current result
  request =
    location: latlng
  geocoder = new gm.Geocoder()
  geocoder.geocode request, callbackGeocoder

  # add circle overlay and bind to marker
  circle = new gm.Circle(
    map: root.map
    radius: 50
    fillColor: "#AA0000"
  )
  # marker on center of the circle
  circle.bindTo "center", marker, "position"
  # add circle to array
  circlesArray.push(circle);

  # add listener for dubble click
  gm.event.addListener marker, "click", ->
    infowindow.open map, marker
    div = $('<div><a href="#">Delete marker</a></div>')

    # add listener for remove marker
    gm.event.addDomListener div.find("a")[0], "click", (event) ->
      event.preventDefault()
      event.stopPropagation()
      deleteOverlays()

    infowindow.setContent div[0]

  # add listener for move action
  gm.event.addListener marker, "dragend", (mouseEvt) ->
    request =
      location: mouseEvt.latLng
    geocoder = new gm.Geocoder()
    geocoder.geocode request, callbackGeocoder


# callback geocode function  
callbackGeocoder = (results, status) ->
  if status is gm.GeocoderStatus.OK
    row = undefined
    i = 0

    while i < results[0].address_components.length
      result = results[0].address_components[i]
      row += "<tr><td>" + result.types[0] + "</td><td>" + result.long_name + "</td></tr>"
      i++

    appendResult(row)
  else
    console.log("error:" + status)

# Deletes all markers in the array by removing references to them
deleteOverlays = ->
  if root.markersArray
    marker.setMap(null) for marker in root.markersArray
    root.markersArray.length = 0
  if root.circlesArray
    circle.setMap(null) for circle in root.circlesArray
    root.circlesArray.length = 0
  appendResult()

# insert results in the box
appendResult = (result = null) ->
  $('.span3').empty().append(result)

initialize()