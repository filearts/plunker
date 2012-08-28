module = angular.module("plunker.url", [])

module.service "url", [ ->
  if _plunker and _plunker.url then _plunker.url
  else
    www: ""
    api: ""
    raw: ""
]