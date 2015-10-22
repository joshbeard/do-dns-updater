# DigitalOcean Dynamic DNS Updater

## Overview

This is a (very) simple Ruby script for updating DNS records on DigitalOcean.

It compares the current external IP address against a specified record and
updates it as needed.  Optionally, it can create a record.

## Limitations

* There's no error handling here and it's a quickly put together script
* Only supports A records

## Usage

```
Usage: update.rb [options]
    -t, --token API_TOKEN            Required: API Token. Can also set via environment variable DO_API_TOKEN
    -d, --domain DOMAIN              Required: Domain name e.g. example.com
    -r, --record RECORD              Required: Record Name e.g. home
    -c, --[no-]create                Optional: Create record if it doesn't exist. Default: true
    -w, --wan URL                    Optional: URL to check WAN IP. Default: http://checkip.dyndns.org:8245/
```

You must provide an API Token, which can be created using DigialOcean's
control panel.  This uses API v2 via the [droplet_kit](https://github.com/digitalocean/droplet_kit)
gem.

### Example

```shell
update.rb -t "3958723947adsf987320" -d foo.com -r home
```

Specifying token via environment variable:

```shell
DO_API_TOKEN="3084098340adf" update.rb -d foo.com -r home
```

## Requirements

A `bundle install` should take care of this:

* [droplet_kit](https://github.com/digitalocean/droplet_kit) gem


## Setup

__1. Clone this repository__

```shell
git clone https://github.com/joshbeard/do-dns-updater
```

__2. Install dependencies__

```shell
bundle install
```

or without bundler: `gem install droplet_kit --no-ri --no-rdoc`

__3. Run script__

```shell
bundle exec update.rb --help
```

