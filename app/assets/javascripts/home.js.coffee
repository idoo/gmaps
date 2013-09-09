# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# short google maps
gm = google.maps

# global variable
root = exports ? this
root.infowindow = new gm.InfoWindow()
root.markersArray = []
root.circlesArray = []
DELETE_TEMPLATE = '<div><a href="#">Delete</a></div>'

class Marker
  constructor: (latlng) ->
    @cleanup()
    @create(latlng)

  create: (latlng) ->
    marker = new gm.Marker(
      position: latlng
      map: root.map
      draggable: true
    )

    root.markersArray.push marker

    request =
      location: latlng
    geocoder = new gm.Geocoder()
    geocoder.geocode request, @callbackGeocoder

    circle = new gm.Circle(
      map: root.map
      radius: 50
      fillColor: "#AA0000"
    )

    circle.bindTo "center", marker, "position"
    circlesArray.push(circle)

    @addListenerForSecondClick(marker)
    @addListenerForMoveMarker(marker)

  addListenerForMoveMarker: (marker) ->
    gm.event.addListener marker, "dragend", (mouseEvt) =>
      request =
        location: mouseEvt.latLng
      geocoder = new gm.Geocoder()
      geocoder.geocode request, @callbackGeocoder

  addListenerForSecondClick: (marker) ->
    gm.event.addListener marker, "click", =>
      infowindow.open map, marker
      div = $(DELETE_TEMPLATE)
      @addListenerForRemoveMarkerAction(div)
      infowindow.setContent div[0]

  addListenerForRemoveMarkerAction: (div) ->
    gm.event.addDomListener div.find("a")[0], "click", (event) =>
      event.preventDefault()
      event.stopPropagation()
      @cleanup()

  cleanup: ->
    if root.markersArray
      marker.setMap(null) for marker in root.markersArray
    if root.circlesArray
      circle.setMap(null) for circle in root.circlesArray
    @appendResult()


  callbackGeocoder: (results, status) =>
    if status is gm.GeocoderStatus.OK
      @appendResult(@buildResults(results[0].address_components))
    else
      console.log("error:" + status)

  buildResults: (addressComponents) ->
    @buildResultsArray(addressComponents).join('')

  buildResultsArray: (addressComponents) ->
    for result in addressComponents
      "<tr><td>#{result.types[0]}</td><td>#{result.long_name}</td></tr>"

  appendResult: (result = null) ->
    $('.span3').empty().append(result)


initialize = ->
  mapOptions =
    center: new gm.LatLng(59.9401975, 30.0906896)
    zoom: 10
    mapTypeId: gm.MapTypeId.ROADMAP

  root.map = new gm.Map($("#map_canvas")[0], mapOptions)

  addListenerForRemoveMarker()

addListenerForRemoveMarker = ->
  gm.event.addListener root.map, "click", (event) ->
    new Marker(event.latLng, "name",
      DELETE_TEMPLATE)

initialize()
