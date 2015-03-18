# Plunker

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/filearts/plunker?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The next generation of lightweight collaborative online editing.

#### WARNING: This repository does not contain the code for what you see running on http://plnkr.co

 > The current code for Plunker is in the repositories listed below

Originally, Plunker was coded in a single repository with different sub-servers existing in the `/servers`
path. The entire application was run on a single server.

However, with increasing popularity, reality decided to come hang out and make everyone's lives difficult.
The solution was simple; since the components of Plunker were designed as 'sub-servers', it should be easy
to split them out and run them separately. However, having different logical entities with different
functions in the same repository doesn't make sense.

I decided to create separate repositories for each of the Plunker servers that are currently deployed on
Nodejitsu. They are as follows:

#### Plunker component repositories

* [plunker_api](//github.com/filearts/plunker_api) The server that connects to a mongodb database and serves requests over a restful api.
* [plunker_www](//github.com/filearts/plunker_www) The server that is responsible for hosting and running the front-end that users see and touch everyday.
* [plunker-run-plugin](//github.com/ggoodman/plunker-run-plugin) The server that allows for previewing of plunks and temporary previews and also does the dynamic transpilation.
* [plunker_collab](//github.com/filearts/plunker_collab) The server that serves the code necessary for collaborative coding as well as doing the actual operational transformation over a browserchannel connection.
* [plunker_embed](//github.com/filearts/plunker_embed) The server that hosts the embedded views of plunks.

### Plunker config files

Each server, once cloned locally, requires one or two `config.json` files to run.

**Servers that use the environment-specific config files `config.development.json` and `config.production.json`:**

* plunker_api
* plunker_www
* plunker_run
* plunker_collab

Only `plunker_embed` uses a single `config.json` file.

**Sample configuration file:**

 > Not all fields are required by each server, but if all are present no harm *should* come to any small animals.
 
```javascript
{
  "host": "hostname.com",
  "url": {
    "www": "http://hostname.com",
    "collab": "http://collab.hostname.com",
    "api": "http://api.hostname.com",
    "embed": "http://embed.hostname.com",
    "run": "http://run.hostname.com",
    "carbonadsH": "OOPS, this is pretty specific to my current deploy",
    "carbonadsV": "OOPS, this is pretty specific to my current deploy"
  },
  "port": 8080,
  "oauth": {
    "github": {
      "id": "series_of_random_chars",
      "secret": "longer_series_of_random_chars"
    }
  }
}
```



# Everything below this point is out of date or incorrect!

 > ...And there be dragons

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
