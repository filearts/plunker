#= require ../../vendor/jquery
#= require ../../vendor/angular

#= require ../../services/panels
#= require ../../services/scratch

uid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


module = angular.module("plunker.panels")

module.directive "plunkerChannel", [ "stream", (stream) ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  template: """
    <div style="display: none;" ng-model="buffer.file.content"></div>
  """
  link: ($scope, el, attr, ngModel) ->
    console.log "Channel", $scope.buffer
    console.log "Parent", stream
    
    child = stream.doc.at(["files", $scope.id, "content"])
    
    console.log "Child", child, child.getText()
    console.log "Stream", stream
    
    child.attach_ace $scope.buffer.session.getDocument(), stream.keep
    
    $scope.$on "$destroy", ->
      child.doc.detach_ace()
]
module.directive "plunkerDescription", [ () ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  template: """
    <div style="display: none;"></div>
  """
  link: ($scope, el, attr, ngModel) ->
    console.log "Channel", $scope.buffer
    
    
    $scope.$on "$destroy", -> #handleDestroy()
]

module.factory "stream", [ () ->
  id: uid(16)
  streaming: false
  buffers: {}
  doc: null
]

module.run [ "$location", "panels", "scratch", "stream", ($location, panels, scratch, stream) ->
  panels.push new class
    name: "streamer"
    order: 3
    size: 340
    title: "Show/hide the streaming panel"
    icon: "icon-fire"
    template: """
      <div class="plnk-stream">
        <plunker-channel ng-repeat="(id, buffer) in buffers"></plunker-channel>
        <plunker-description ng-model="scratch.description"></plunker-description>
        <div ng-hide="stream.streaming">
          <h1>Streaming</h1>
          <p>
            Streaming enables real-time collaboraboration on Plunker. When you
            join a stream, the contents of your editor are kept in sync with the
            stream and reflect changes made by others in the same stream.
          </p>
          <form ng-submit="startStream(stream.id)">
            <input class="mediumtext" ng-model="stream.id" size="32" />
            <button class="btn btn-primary" type="submit">Stream</button>
          </form>
          <h4>What happens if I hit save?</h4>
          <p>
            The current contents of your plunk will be saved as if you had
            made all the changes to the files yourself. No one else in the stream
            will be affected at all by saving your state.
          </p>
          <h4>What happens if I load a template?</h4>
          <p>
            If you load a template, the resulting files will be sent to
            everyone else in the stream as if you had made the changes yourself.
            This is usually not what you want to do.
          </p>
        </div>
      </div>
    """
    getConnection: ->
      location = window.location
      @conn ||= new sharejs.Connection("#{location.protocol}//#{location.host}/channel")
    
    getLocalState: ->
      state =
        description: scratch.plunk.description
        files: []
      
      for filename, file of scratch.getValidFiles()
        #TODO: Hack using AngularJS internals
        state.files.push
          content: file.content
          filename: file.filename
    
      state
      
    join: (id = uid()) ->
      self = @
      
      scratch.loading = true
      
      @getConnection().open "stream:#{id}", "json", (err, doc) ->
        if err then return console.error "message", "Connection error", """
          Failed to join the stream #{id}. Please double-check that you entered
          the right stream id. If the problem persists, please contact the
          administrator.
        """
        
        if doc.created is true
          # Reset the channel to the current local state
          doc.submitOp [ { p: [], od: doc.snapshot, oi: self.getLocalState() } ], (err) ->
            if err then console.error "error", "Error setting initial state"
            else self.start(id, doc, true)
            self.scope.$apply -> scratch.loading = false
        else
          self.start(id, doc)
          self.scope.$apply -> scratch.loading = false
    
    start: (id, @doc, keep = false) ->
      self = @
      
      unless keep
        state = @doc.get()
        json =
          description: state.description or ""
          files: {}
        
        for id, file of state.files
          json.files[file.filename] = angular.copy(file)
          
        console.log "Resetting to", json
        
        scratch.reset(json)
        
      console.log "Started", @doc.get()
      
      self.scope.$apply ->
        stream.streaming = true
        stream.doc = self.doc
        stream.buffers = buffers
        stream.keep = keep
        
        self.scope.buffers = buffers
        
        
      @doc.on "change", (events) ->
        console.log "sharejs::change", arguments...
        ###
        angular.forEach events, (e) ->
          if e.p.length then switch e.p[0]
            when "description" then self.remote.trigger "description:change", e.oi or ""
            when "channels"
              # TODO: This first comparison is VERY inefficient
              if e.p.length == 1 and not _.isEqual(self.getLocalState().channels, e.oi) then self.remote.trigger "channels:reset", e.oi
              else if e.p.length == 2
                if e.od? then self.remote.trigger "channels:remove", e.od
                else if e.oi? then self.remote.trigger "channels:add", e.oi
              else if e.p.length == 3
                self.remote.trigger "channels:rename", e.oi, e.od, e.p[2]
          else
            self.remote.trigger "description:change", e.oi.description
            self.remote.trigger "channels:reset", e.oi.channels, keep: false
        ###
          
    link: ($scope, el, attrs) ->
      self = @
      self.scope = $scope
      
      $scope.stream = stream
      $scope.buffers = {}
      
      $scope.startStream = (id) ->
        alert "Coming soon"
        #self.join(id)
        
      
    deactivate: ($scope, el, attrs) ->
          
    activate: ($scope, el, attrs) ->
]

# This is some utility code to connect an ace editor to a sharejs document.

Range = require("ace/range").Range

# Convert an ace delta into an op understood by share.js
applyToShareJS = (editorDoc, delta, doc) ->
  # Get the start position of the range, in no. of characters
  getStartOffsetPosition = (range) ->
    # This is quite inefficient - getLines makes a copy of the entire
    # lines array in the document. It would be nice if we could just
    # access them directly.
    lines = editorDoc.getLines 0, range.start.row
      
    offset = 0

    for line, i in lines
      offset += if i < range.start.row
        line.length
      else
        range.start.column

    # Add the row number to include newlines.
    offset + range.start.row

  pos = getStartOffsetPosition(delta.range)

  switch delta.action
    when 'insertText' then doc.insert pos, delta.text
    when 'removeText' then doc.del pos, delta.text.length
    
    when 'insertLines'
      text = delta.lines.join('\n') + '\n'
      doc.insert pos, text
      
    when 'removeLines'
      text = delta.lines.join('\n') + '\n'
      doc.del pos, text.length

    else throw new Error "unknown action: #{delta.action}"
  
  return

# Attach an ace editor to the document. The editor's contents are replaced
# with the document's contents unless keepEditorContents is true. (In which case the document's
# contents are nuked and replaced with the editor's).
window.sharejs.extendDoc 'attach_ace', (editorDoc, keepEditorContents) ->
  console.log "attach_ace, this", @
  console.log "attach_ace, args..", arguments...
  #throw new Error 'Only text documents can be attached to ace' unless @provides['text']

  doc = this
  editorDoc.setNewLineMode 'unix'

  check = ->
    window.setTimeout ->
        editorText = editorDoc.getValue()
        otText = doc.getText()

        if editorText != otText
          console.error "Text does not match!"
          console.error "editor: #{editorText}"
          console.error "ot:     #{otText}"
          # Should probably also replace the editor text with the doc snapshot.
      , 0

  if keepEditorContents
    doc.del 0, doc.getText().length
    doc.insert 0, editorDoc.getValue()
  else
    editorDoc.setValue doc.getText()

  check()

  # When we apply ops from sharejs, ace emits edit events. We need to ignore those
  # to prevent an infinite typing loop.
  suppress = false
  
  # Listen for edits in ace
  editorListener = (change) ->
    return if suppress
    applyToShareJS editorDoc, change.data, doc

    check()

  editorDoc.on 'change', editorListener

  # Listen for remote ops on the sharejs document
  docListener = (op) ->
    suppress = true
    applyToDoc editorDoc, op
    suppress = false

    check()


  # Horribly inefficient.
  offsetToPos = (offset) ->
    # Again, very inefficient.
    lines = editorDoc.getAllLines()

    row = 0
    for line, row in lines
      break if offset <= line.length

      # +1 for the newline.
      offset -= lines[row].length + 1

    row:row, column:offset

  doc.on 'insert', (pos, text) ->
    suppress = true
    editorDoc.insert offsetToPos(pos), text
    suppress = false
    check()

  doc.on 'delete', (pos, text) ->
    suppress = true
    range = Range.fromPoints offsetToPos(pos), offsetToPos(pos + text.length)
    editorDoc.remove range
    suppress = false
    check()

  doc.detach_ace = ->
    doc.removeListener 'remoteop', docListener
    editorDoc.removeListener 'change', editorListener
    delete doc.detach_ace

  return
