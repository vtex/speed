module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')

  environment = process.env.VTEX_HOST or 'vtexcommercestable'

  verbose = grunt.option('verbose')
  
  open = if pkg.accountName then "http://#{pkg.accountName}.vtexlocal.com.br/?debugcss=true&debugjs=true" else undefined

  errorHandler = (err, req, res, next) -> 
    errString = err.code?.red ? err.toString().red
    grunt.log.warn(errString, req.url.yellow)
              
  config =
    clean:
      main: ['build']

    copy:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**', '!**/*.coffee', '!**/*.less', '!sprite/**/*']
          dest: "build/"
        ]

    coffee:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**/*.coffee']
          dest: "build/"
          ext: '.js'
        ]

    less:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**/*.less']
          dest: "build/"
          ext: '.css'
        ]

    cssmin:
      main:
        expand: true
        cwd: 'build/'
        src: ['*.css', '!*.min.css']
        dest: 'build/'
        ext: '.min.css'

    uglify:
      options:
        mangle: false
      main:
        files: [{
          expand: true
          cwd: 'build/'
          src: ['*.js', '!*.min.js']
          dest: 'build/'
          ext: '.min.js'
        }]

    sprite:
      all: 
        src: 'src/sprite/*.png'
        destImg: 'build/spritesheet.png'
        destCSS: 'build/sprite.css'

    imagemin:
      main:
        files: [
          expand: true
          cwd: 'build/'
          src: ['**/*.{png,jpg,gif}']
          dest: 'build/'
        ]

    connect:
      http:
        options:
          hostname: "*"
          open: open
          port: process.env.PORT || 80
          middleware: [
            (req, res, next) ->
              end = res.end
              res.end = (data, encoding) ->
                if data
                  data = data.replace(new RegExp(environment, "g"), "vtexlocal")
                res.end = end
                res.end data, encoding
              next()
            require('connect-livereload')({disableCompression: true})
            require('connect-http-please')(replaceHost: ((h) -> h.replace("vtexlocal", environment)), {verbose: verbose})
            (req, res, next) -> req.headers.host = req.headers.host.replace("vtexlocal", environment); next()
            require('connect-tryfiles')('**', "http://portal.#{environment}.com.br:80", {cwd: 'build/', verbose: verbose})
            require('connect').static('./build/')
            errorHandler
          ]

    watch:
      options:
        livereload: true
      coffee:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      less:
        options:
          livereload: false
        files: ['src/**/*.less']
        tasks: ['less']
      images:
        files: ['src/**/*.{png,jpg,gif}']
        tasks: ['imagemin']
      css:
        files: ['build/**/*.css']
      main:
        files: ['src/**/*.html', 'src/**/*.js', 'src/**/*.css']
        tasks: ['copy']
      grunt:
        files: ['Gruntfile.coffee']

  tasks =
    # Building block tasks
    build: ['clean', 'copy:main', 'sprite', 'coffee', 'less', 'imagemin']
    min: ['uglify', 'cssmin'] # minifies files
    # Deploy tasks
    dist: ['build', 'min'] # Dist - minifies files
    test: []
    # Development tasks
    default: ['build', 'connect', 'watch']
    devmin: ['build', 'min',
             'connect:http:keepalive'] # Minifies files and serve

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks
