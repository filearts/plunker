# Plunker

The next generation of lightweight collaborative online editing.

# Usage

```
git clone git://github.com/filearts/plunker.git
git submodule update --init

npm install

node server.js
```

## Editor API

### `POST /edit/`

You can send a `POST` request to `/edit/` to bootstrap the editor with the basic structure of a plunk.  The JSON format for this is described below.

```javascript
{
  "description": "Description of Plunk",
  "tags": ["array", "of", "tags"],
  "files": [
    {
      "filename": "index.html",
      "content": "<html><script src=\"script.js\"></script></html>"
    },
    {
      "filename": "script.js",
      "content": "alert('hello world');"
    }
  ]
}