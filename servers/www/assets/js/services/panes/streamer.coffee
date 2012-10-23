#= require ../../services/panels
#= require ../../services/scratch
#= require ../../services/url

#= require ../../directives/discussion

uid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


synchro = new class Synchro
  constructor: (@scope) ->
    @localEvents = 0
    @remoteEvents = 0
  
  handleRemoteEvent: (cb) ->
    return false if @localEvents > @remoteEvents
    @remoteEvents++
    cb()
    @remoteEvents--
    true
  
  handleLocalEvent: (cb) ->
    return false if @remoteEvents > @localEvents
    @localEvents++
    cb()
    @localEvents--
    true

resetFiles = (scratch, files) ->
  # We don't want to reset the *whole* scratch here as that would result
  # in changing the active plunk to a blank one. We will just adjust the
  # plunk's description and tags and reset the buffers.
  new_files = []
  for channel, file of files
    new_files.push angular.extend file,
      channel: channel
  
  scratch.buffers.reset(new_files)
  scratch.buffers.activate(index) if index = scratch.buffers.findBy("filename", "index.html")

resetScratch = (scratch, state) ->
  scratch.plunk.description = state.description
  scratch.plunk.tags = state.tags

  resetFiles(scratch, state.files)
  
module = angular.module("plunker.panels")

module.directive "plunkerChannel", [ "stream", (stream) ->
  restrict: "E"
  replace: true
  template: """
    <div style="display: none;"></div>
  """
  link: ($scope, el, attr) ->
    buffer = $scope.buffer
    
    #
    finalize = (channel) ->
      # Sync the content
      filename = channel.at("filename")
      content = channel.at("content")
      content.attach_ace(buffer.session, stream.keep)
      
      # Watch for remote changes to filename
      channel.on "replace", (key, previous, current) ->
        if key is "filename" then synchro.handleRemoteEvent ->
          $scope.$apply -> buffer.filename = current
      
      # Watch for local changes to filename
      $scope.$watch "buffer.filename", (new_filename, old_filename) ->
        if new_filename isnt old_filename then synchro.handleLocalEvent ->
          filename.set(new_filename)
      
      $scope.$on "$destroy", ->
        content.detach_ace()
        
        synchro.handleLocalEvent ->
          channel.remove()
          delete buffer.channel
      
      
    # No channel has been created yet. This is a new file, created locally
    unless buffer.channel
      buffer.channel = uid(10)
      
      state =
        filename: buffer.filename
        content: buffer.content
    
      channel = stream.doc.at(["files", buffer.channel])
      channel.set state, (err) ->
        if err then console.error("Error creating channel")
        else finalize(channel)
    else finalize(stream.doc.at(["files", buffer.channel]))
]

module.factory "stream", [ () ->
  id: uid(16)
  streaming: false
  doc: null
]


module.requires.push("plunker.discussion", "plunker.url")

module.run [ "$location", "$timeout", "$q", "panels", "scratch", "stream", "url", ($location, $timeout, $q, panels, scratch, stream, url) ->
  panels.push new class
    name: "streamer"
    order: 3
    size: 340
    title: "Real-time collaboration"
    icon: "icon-fire"
    template: """
      <div id="panel-streamer" class="plnk-stream" ng-switch="stream.streaming">
        <div ng-switch-when="streaming">
          <plunker-channel ng-repeat="buffer in scratch.buffers.queue"></plunker-channel>
          <div class="status">
            <h4>Streaming enabled</h4>
            Stream: <a ng-href="{{url.www}}/edit/?p=streamers={{stream.id}}" target="_blank" title="Link to this stream"><code class="stream-id" ng-bind="stream.id"></code></a>
            <button class="btn btn-mini btn-danger" ng-click="stopStream()" title="Disconnect from stream">
              <i class="icon-stop"></i> Disconnect
            </button>
          </div>
          <plunker-discussion room="stream.id"></plunker-discussion>
        </div>
        <div ng-switch-default>
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
        tags: scratch.plunk.tags
        files: {}
      state
      
    join: (id = uid()) ->
      self = @
      deferred = $q.defer()
      
      @getConnection().open "stream:#{id}", "json", (err, doc) ->
        if err then return deferred.reject "Stream error: Unable to join stream"
        
        stream.id = id
        stream.doc = doc
        stream.keep = doc.created is true
        stream.streaming = "streaming"

        if stream.keep
          # Reset the channel to the current local state
          doc.submitOp [ { p: [], od: doc.snapshot, oi: self.getLocalState() } ], (err) ->
            self.scope.$apply ->
              if err
                doc.close()
                deferred.reject("Stream error: Error setting initial state")
              else
                deferred.resolve(stream)
        else
          self.scope.$apply -> synchro.handleRemoteEvent ->
            deferred.resolve(stream)
      
      deferred.promise
    
    stop: ->
      self = @
      
      if self.doc
        self.scope.scratch = null

        stream.doc.close()
        stream.streaming = false
        stream.doc = null
        stream.id = uid()
          
      search = $location.search()
      delete search.s
      
      scratch.unlock()
      
      $location.search(search).replace()
      
    
    start: (stream) ->
      self = @
      self.doc = stream.doc
      
      resetScratch(scratch, stream.doc.get()) unless stream.keep
      
      scratch.lock("Connected to stream")

      # Assign the scratch to the local scope which will trigger creation of
      # custom directives for each channel
      self.scope.scratch = scratch
      
      files = @doc.at("files")
      
      files.on "insert", (pos, data) ->
        synchro.handleRemoteEvent ->
          unless scratch.buffers.findBy("channel", pos)
            self.scope.$apply -> scratch.buffers.add angular.extend(data, channel: pos)
      
      files.on "delete", (pos, data) ->
        synchro.handleRemoteEvent ->
          self.scope.$apply -> scratch.buffers.remove(buffer) if buffer = scratch.buffers.findBy("channel", pos)
          
      search = $location.search()
      search.s = stream.id
      
      $location.search(search).replace()
      
    link: ($scope, el, attrs) ->
      self = @
      self.scope = $scope
      
      synchro.scope = $scope
      
      $scope.url = url
      $scope.stream = stream
      
      $scope.startStream = (id) ->
        scratch.loading = true
        self.join(id).then (id, doc, keep) ->
          self.start(id, doc, keep)
          scratch.loading = false
        , (error) ->
          alert(error)
          scratch.loading = false
      
      $scope.stopStream = ->
        self.stop()
      
      if id = $location.search().s then $timeout ->
        $scope.startStream(id)
      , 500 #TODO: HACK!
      
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
window.sharejs.extendDoc 'attach_ace', (session, keepEditorContents) ->
  doc = this
  editorDoc = session.getDocument()
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

  # Not needed because we ALWAYS either create a new channel or keep the old one
  #if keepEditorContents
  #  doc.del 0, doc.getText().length
  #  doc.insert 0, editorDoc.getValue()
  #else
    # Already done by custom code
    # editorDoc.setValue doc.getText()

  check()

  # When we apply ops from sharejs, ace emits edit events. We need to ignore those
  # to prevent an infinite typing loop.
  suppress = false
  
  # Listen for edits in ace
  editorListener = (change) ->
    return if suppress
    applyToShareJS editorDoc, change.data, doc

    check()

  session.on 'change', editorListener

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
    session.removeListener 'change', editorListener
    delete doc.detach_ace

  return