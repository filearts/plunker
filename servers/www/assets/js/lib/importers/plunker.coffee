((plunker) ->
  
  plunkerRegex = ///
    ^
      \s*                   # Leading whitespace
      plunker:              # Optional anchor
      ([a-zA-Z0-9]+)        # Plunk ID
      \s*                   # Trailing whitespace
    $
  ///i

  
  plunker.importers ||= []
  plunker.importers.push (source, success, next) ->
    unless matches = source.match(plunkerRegex) then next()
    else
      promise = $.ajax "http://plunker.no.de/api/v1/plunks/#{matches[1]}",
        dataType: "json"
        type: "GET"
        error: -> next("Import failed")
        success: (data) ->
          json =
            source:
              type: "plunker_no_de"
              url: data.html_url
              title: "old_plunk:#{data.id}"
            files: {}
            
          json.description = json.source.description = data.description if data.description
          
          for filename, file of data.files
            json.files[filename] =
              content: file.content
            
          success(json)
      
  
)(@plunker or @plunker = {})