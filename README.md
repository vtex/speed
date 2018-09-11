# VTEX Speed

VTEX Store development tools - reverse proxy, compilation, minification, optimization and more!

## Presentation - VTEX Day 2014

Watch a presentation about VTEX Speed here (pt-BR): http://firstdoit.github.io/presentations/vtex-day-2014

## Pre-requisites

* Node - http://nodejs.org/
* Grunt - https://gruntjs.com/

## Install

Clone this repo or download and unzip it.

## Quick Start

**Before continuing**, please edit the `accountName` key to the `package.json` file. For example:

```json
    {
      "name": "vtex-speed",
      "accountName": "your-store-account-name",
    }
```

Enter the folder you cloned or downloaded, install dependencies and run `npm start`:

```shell
    cd speed
    npm install
    npm start
```

First, open your browser here to authenticate:  

http://your-store-account-name.vtexlocal.com.br/admin/Site/Login.aspx

Then, open a normal page, like your home:

http://your-store-account-name.vtexlocal.com.br/?debugcss=true&debugjs=true

**Important**  You should replace `your-store-account-name` with the accountName of your store. Who would guess, huh?


Nice! Live Reload has reloaded that stylesheet for you.

## Features

All files in `src/` are compiled, optimized and copied to `build/` when you run `grunt`.

You can further configure this process editing `Gruntfile.coffee`.

Currently supported:

- LiveReload of assets in HTTP and HTTPS
- Coffee compilation
- LESS compilation
- SASS compilation
- JS and CSS Minification
- Optimize Images
- Create Icons SpriteSheet

Check the `src/` directory for examples.

### Spritesheets

To create spritesheets for your icons by putting your icons png files into the src/sprite directory. Then you can use render your icons by using the class icon-<filename>.

### Pages reverse proxy

You can use VTEX Speed serve HTML pages while developing, simply put your HTML files inside `src/` directory. You can see example page [http://your-store-account-name.vtexlocal.com.br/page-example/](http://your-store-account-name.vtexlocal.com.br/page-example/).

### Compress option

You can use the flag `--compress` to develop with minified files (JS, CSS, and SASS).

### Changing default port

You can easily change the proxy port by setting the PORT environment variable, e.g. `PORT=9000 npm start`

## Discover new Grunt plugins

There are a **ton** of available Grunt plugins for your every need.

Go to http://gruntjs.com/plugins for a complete list.

If you think there's a plugin that's great for everybody, why don't you [fork this repo and open a pull request](https://github.com/vtex/speed/fork)?

## Feedback

We always want to hear you! Please report any problems to the issues page:

https://github.com/vtex/speed/issues

## FAQ

### What is `ECONNRESET`?

The HTTP response socket hung up before sending a complete reply.  
You probably manually stopped a request on your browser.  
Thus, the proxy shouted: "I was receiving a response and it stopped abruptly!"

## Release History

- 2018-09-11    v5.0.0      Add compress option. Allow to use another port. Add support for SASS.

- 2016-05-06    v3.0.0      Update grunt to major 1 and other dependencies

- 2015-03-16    v2.1.0      Update connect-http-please, separate middlewares from Gruntfile

- 2015-03-16    v2.0.0      Replace `connect-tryfiles` with `serve-static` and `proxy-middleware`, adding support to "vteximg" host proxying. Update deps. **Important:** `accountName` is now a required property in the `package.json` file.

## License

MIT © [VTEX](https://github.com/vtex)
