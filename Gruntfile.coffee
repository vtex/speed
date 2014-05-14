module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')

  environment = process.env.VTEX_HOST or 'vtexcommerce'

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
          src: ['**', '!**/*.coffee', '!**/*.less']
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

    imagemin:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**/*.{png,jpg,gif}']
          dest: 'build/'
        ]

    sprite:
      all: 
        src: 'src/sprite/*.png'
        destImg: 'src/spritesheet.png'
        destCSS: 'src/sprite.less'

    connect:
      http:
        options:
          hostname: "*"
          open: open
          port: 80
          middleware: [
            require('connect-livereload')({disableCompression: true})
            require('connect-http-please')(replaceHost: ((h) -> h.replace("vtexlocal", environment)), {verbose: verbose})
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
    build: ['clean', 'sprite', 'copy:main', 'coffee', 'less', 'imagemin']
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
