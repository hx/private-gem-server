# Private Gem Server

This gem provides a [Gem in a Box](https://github.com/geminabox/geminabox) implementation that pulls gems from git sources, and builds them, whenever a client requests a list of gems.

## Installation

    gem install private-gem-server
    
## Usage

The gem comes with the `private-gem-server` executable, which wraps the `thin` executable. It takes exactly the same command-line arguments as the [Thin web server](http://code.macournoyer.com/thin/). Run `thin -h` to see them.

    sudo private-gem-server -p 80 start
    
## Configuration

Customize this gem using environment variables:

#### GEM_STORE

The directory in which gems (and other working files) should be stored.

#### GEM_SERVER_LOG

Path of a log file to which the server should write.

#### GEM_SOURCES

Path of a YAML file containing a list of gems to be served.

## Sources

Here's an example sources file:

```yaml
keys:
  my_private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpAIBAAKCAQEA1Wdr4g6o62CwrNFcyVc4dQi3mrQbffhceXHD6NtnfjtrFZ7K
    XKNh33X1c42D/THIS/WOULD/BE/MUCH/LONGER/IF/IT/WERE/REAL/dynzKCoLb
    JwyMC+KerlXfxDSCWzE6z7bcA38dXn3hwnbokowZro40mo/NTwqY6Q==
    -----END RSA PRIVATE KEY-----
    
gems:
  "secret-component":
    type: git
    url: git@github.com:hx/secret-component
    key: my_private_key
  
  "very-secret-component":
    type: git
    url: git@github.com:hx/very-secret-component
    key: my_private_key
```

For now, `git` is the only supported source. Others will come.

## Notes

- This is a premature gem with no test coverage. Don't use it.
