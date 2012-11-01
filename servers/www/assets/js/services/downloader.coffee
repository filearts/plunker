#= require ../vendor/jszip


module = angular.module("plunker.downloader", [])

module.factory "downloader", ["$location", ($location) ->
  download: (json, saveAs = "plunker.zip") ->
    zip = new JSZip()
    zip.file(file.filename, file.content) for filename, file of json.files
    
    url = "data:application/zip;base64," + zip.generate()
    
    link = document.createElement("a")
    
    if link.download?
      link.setAttribute("href", url)
      link.setAttribute("download", saveAs)
      
      event = document.createEvent('MouseEvents');
      event.initMouseEvent('click', true, true, window, 1, 0, 0, 0, 0, false, false, false, false, 0, null)
      
      link.dispatchEvent(event)
    else
      window.open(url, "_blank", "")
    
]