// Ghost Configuration

var path = require('path'),
    config;

config = {
  // ### Production
  // When running Ghost in the wild, use the production environment
  // Configure your URL and mail settings here
  production: {
    url: 'http://{{ server_hostname }}',
    mail: {},
    database: {
      client: 'sqlite3',
      connection: {
        filename: path.join(__dirname, '/content/data/ghost.db')
      },
      debug: false
    },
    server: {
      host: '127.0.0.1',
      port: '2368'
    }
  }
};
