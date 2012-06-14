((plunker) ->
  
  githubRegex = ///
    ^
      \s*                   # Leading whitespace
      (?:                   # Optional protocol/hostname
        (?:https?\://)?     # Protocol
        gist\.github\.com/  # Hostname
      )?
      ([0-9]+|[0-9a-z]{20}) # Gist ID
      (?:#.+)?              # Optional anchor
      \s*                   # Trailing whitespace
    $
  ///i

  
  plunker.importers ||= []
  plunker.importers.push (source, success, next) ->
    unless matches = source.match(githubRegex) then next()
    else
      promise = $.ajax "https://api.github.com/gists/#{matches[1]}",
        dataType: "jsonp"
        error: -> next("Import failed")
        success: (data) ->
          if data.meta.status >= 400 then next(data.data.message)
          else
            gist = data.data
    
            json =
              source:
                type: "gist"
                url: gist.html_url
                title: "gist:#{gist.id}"
              files: {}
            
            json.description = json.source.description = gist.description if gist.description
            
            for filename, file of gist.files
              json.files[filename] =
                content: file.content 
            
            success(json)
      
  
)(@plunker or @plunker = {})