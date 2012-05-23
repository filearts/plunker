Database = require("./stores/memory").Database

module.exports = 
  users: new Database(filename: "/tmp/users.json")
  sessions: new Database(filename: "/tmp/sessions.json")
  plunks: new Database
    filename: "/tmp/plunks.json"
    comparator: (item) -> Date.parse(item.updated_at or item.created_at)