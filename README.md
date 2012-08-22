# Plunker

The next generation of lightweight collaborative online editing.

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