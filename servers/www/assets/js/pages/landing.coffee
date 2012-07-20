#= require ../vendor/jquery
#= require ../vendor/angular
#= require ../vendor/angular-resource

#= require ../modules/plunker
#= require ../directives/userpanel
#= require ../modules/plunks
#= require ../modules/gallery

#= require ../controllers/importer


angular.module("plunker.landing", ["plunker", "plunker.userpanel", "plunker.plunks", "plunker.gallery"])