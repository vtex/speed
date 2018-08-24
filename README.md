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

**Advanced:** You can easily change the proxy port by setting the PORT environment variable, e.g. `PORT=9000 npm start`

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

To optimize your images before uploading them to vtex, simply put your image files into src/Images directory.
To create spritesheets for your icons by putting your icons png files into the src/sprite directory. Then you can use render your icons by using the class icon-<filename>
To develop Javascript, simply insert your javascript files into src/Scripts directory.

But, hey, there's more!

---

### Files reverse proxy

You can use vtex speed to just replace the files in your store while developing, simply put your files into src/ReverProxy directory

---
### CSS 

To develop your store styles with raw css styles, you should simply white your css code into the folder src/Styles/css. 
Then run one of this commands:
`````bash
$ npm start
$ npm run css-min     # minimize the result css and js files on dev time
$ grunt
$ grunt --compress   # minimize the result css and js files on dev time
`````

---
### SASS 
 
To develop your store styles using sass, you should simply white your sass code into the folder src/Styles/sass. 
Then run one of this commands:
`````bash
$ npm run sass
$ npm run sass-min     # minimize the result css and js files on dev time
$ grunt --sass
$ grunt --sass --compress   # minimize the result css and js files on dev time
`````

**Attention** To include npm libraries you can use the tilde syntax. For example:
```bash
$ npm install --save bootstrap@">=4.0"
```
```css
/** 
    To import bootstrap 4 sass source
*/
@import "~bootstrap/scss/bootstrap.scss";
```

---
### LESS 
 
To develop your store styles using less, you should simply white your less code into the folder src/Styles/less. 
Then run one of this commands:
`````bash
$ npm run less
$ npm run less-min     # minimize the result css and js files on dev time
$ grunt --less
$ grunt --less --compress   # minimize the result css and js files on dev time
`````
**Attention** To include npm libraries you can use the tilde syntax. For example:
```bash
$ npm install --save bootstrap@">=3.0 <4.0"
```
```css
/** 
    To import bootstrap 3 less source.
*/
@import "~bootstrap/less/bootstrap.less";
```

---
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

- 2016-05-06    v3.0.0      Update grunt to major 1 and other dependencies

- 2015-03-16    v2.1.0      Update connect-http-please, separate middlewares from Gruntfile

- 2015-03-16    v2.0.0      Replace `connect-tryfiles` with `serve-static` and `proxy-middleware`, adding support to "vteximg" host proxying. Update deps. **Important:** `accountName` is now a required property in the `package.json` file.

## License

MIT © [VTEX](https://github.com/vtex)
