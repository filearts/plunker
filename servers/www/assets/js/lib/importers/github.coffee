((plunker) ->
  
  githubRegex = ///
    ^
      \s*                   # Leading whitespace
      (?:                   # Optional protocol/hostname
        (?:https?\://)?   # Protocol
        gist\.github\.com/ # Hostname
      )?
      ([0-9a-z]+)           # Gist ID
      (?:#.+)?              # Optional anchor
      \s*                   # Trailing whitespace
    $
  ///i

  
  plunker.importers ||= []
  plunker.importers.push (source, success, next) ->
    unless matches = source.match(githubRegex) then next()
    else
      promise = $.ajax "https://api.github.com/gists/#{matches[1]}",
        timeout: 8 * 1000
        dataType: "jsonp"
        error: -> next("Import failed")
        success: (data) ->
          if data.meta.status >= 400 then next("Import failed")
          else
            gist = data.data
    
            json =
              description: gist.description
              files: {}
            
            for filename, file of gist.files
              json.files[filename] =
                content: file.content 
            
            success(json)
      
  
)(@plunker or @plunker = {})