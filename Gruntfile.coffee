#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    watch:
      files: ["sass/*", "coffee/*"]
      tasks: "default"

      jasmine:
        files: ['src/**/*.js', 'specs/**/*.js']
        tasks: 'jasmine:build'

    sass:
      dist:
        files:
          "dist/css/base.css": "sass/base.scss"

    coffee:
      compile:
        files:
          "js/app.js": "coffee/app.coffee"

    concat:
      dist:

        #i.e. src: ['js/libs/mediaCheck.js', 'js/app.js'],
        src: ["js/app.js"]

        #change this to a site specific name i.e. uwg.js or dty.js
        dest: "dist/js/forge.js"

    modernizr:
      devFile: "js/libs/modernizr-dev.js"
      outputFile: "dist/js/libs/modernizr.min.js"
      extra:
        shiv: true
        printshiv: false
        load: true
        mq: false
        cssclasses: true

      extensibility:
        addtest: false
        prefixed: false
        teststyles: false
        testprops: false
        testallprops: false
        hasevents: false
        prefixes: false
        domprefixes: false

      uglify: true
      parseFiles: true
      matchCommunityTests: false

    ###targethtml:
      dev:
        src: "index.html"
        dest: "dist/index.html"

      prod:
        src: "index.html"
        dest: "dist/index.html"###

    clean: ["js/*.concat.js", "dist", "docs"]
    styleguide:
      dist:
        files:
          "docs/scss": "sass/*.scss"

    exec:
      docco:
        command: "docco -o docs/js/ js/*.js js/*.coffee"

    jasmine:
      src: 'dist/**/*.js'
      options:
        specs: 'test/spec/*Spec.js'
        helpers: 'test/spec/*Helper.js'


  grunt.loadNpmTasks "grunt-contrib"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-sass"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-jasmine"
  grunt.loadNpmTasks "grunt-modernizr"
  grunt.loadNpmTasks "grunt-notify"
  grunt.loadNpmTasks "grunt-styleguide"
  grunt.loadNpmTasks "grunt-targethtml"
  grunt.loadNpmTasks "grunt-exec"

  # Default task.
  grunt.registerTask "default", ["coffee", "sass", "concat"]
  grunt.registerTask "dist", ["coffee", "concat", "targethtml:prod", "modernizr", "docs"] # Needs min task added
  grunt.registerTask('docs', ['styleguide', 'exec:docco', 'notify']);
