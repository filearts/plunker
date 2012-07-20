#= require ../vendor/jquery
#= require ../vendor/angular
#= require ../vendor/angular-resource

#= require ../modules/plunker

#= require ../directives/userpanel
#= require ../directives/layout
#= require ../directives/ace


angular.module("plunker.landing", ["plunker", "plunker.userpanel", "plunker.layout", "plunker.ace"])