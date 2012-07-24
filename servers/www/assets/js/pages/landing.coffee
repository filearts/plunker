#= require ../vendor/jquery
#= require ../vendor/angular

#= require ../services/plunks

#= require ../directives/userpanel
#= require ../directives/card

#= require ../controllers/importer
#= require ../controllers/gallery

angular.module("plunker.landing", ["plunker.userpanel", "plunker.plunks", "plunker.card", "plunker.importer", "plunker.gallery"])