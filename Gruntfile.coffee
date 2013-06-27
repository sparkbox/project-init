#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    watch:

      stylesheets:
        files: "scss/**/*"
        tasks: "compass:dev"

      livereload:
        files: "dist/css/*"
        options:
          livereload: true

      images:
        files: "opt-imgs/*"
        tasks: "optimizeImages"

      partials:
        files: "partials/*"
        tasks: "concat:partials"
        options:
          livereload:true

      javascript:
        files: ["coffee/*", "js/*.js"]
        tasks: "javascript:dev"

      jsTesting:
        files: "dist/js/*.js"
        tasks: "jasmine"

      cukes:
        files: ["features/*.feature", "features/step_definitions/*.coffee"]
        tasks: "cucumberjs"

      publicDirectory:
        files: [ "public/**/*" ]
        tasks: "default"

    compass:
        dev:
          options:
            environment: 'dev'
        dist:
          options:
            environment: 'production'

    coffee:
      compile:
        files:
          "js/app.js": "coffee/app.coffee"
      jasmine_specs:
        files: grunt.file.expandMapping(["specs/*.coffee"], "specs/js/", {
          rename: (destBase, destPath) ->
            destBase + destPath.replace(/\.coffee$/, ".js").replace(/specs\//, "")
        })

    concat:
      partials:
        options:
          process: true
        files:
          # destination as key, sources as value
          "dist/index.html": ["partials/_header.html", "partials/_home-page.html", "partials/_footer.html"]
          "dist/404.html": "partials/404.html"
      js:
        src: ["js/libs/*", "js/app.js"]
        #put it in dist/
        dest: "dist/js/<%= pkg.name %>.js"

    modernizr:
      devFile: "dist/js/modernizr.js"
      outputFile: "dist/js/modernizr.js"
      extra:
        shiv: true
        printshiv: true
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

    clean:
      all:
        src: "dist/*"
        dot: true # clean hidden files as well

    copy:
      main:
        files: [
          expand: true
          cwd:'public/'
          src: ["**"]
          dest: "dist/"
        ]
      img:
        files: [
          expand: true
          cwd:'opt-imgs/'
          src: ["**"]
          dest: "dist/img"
        ]

    jasmine:
      src: "dist/js/*.js"
      options:
        specs: "specs/js/*Spec.js"
        helpers: "specs/js/*Helper.js"
        vendor: ["public/js/jquery-1.9.1.min.js", "specs/lib/*.js"]

    cucumberjs: {
      files: 'features',
      options: {
        steps: "features/step_definitions"
      }
    }

    imageoptim:
      files: ["opt-imgs"]
      options:
        imageAlpha:true

    plato:
      complexity:
        files:
          'reports/js-complexity': ['dist/**/*.js']

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-compass"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-jasmine"
  grunt.loadNpmTasks "grunt-cucumber"
  grunt.loadNpmTasks "grunt-modernizr"
  grunt.loadNpmTasks "grunt-notify"
  grunt.loadNpmTasks "grunt-exec"
  grunt.loadNpmTasks "grunt-plato"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-imageoptim"

  # NOTE: this has to wipe out everything
  grunt.registerTask "root-canal", [ "clean:all", "copy:main", "copy:img"]

  grunt.registerTask "optimizeImages", ["imageoptim", "copy:img"]

  # Clean, compile and concatenate JS
  grunt.registerTask "javascript:dev", [ "coffee", "concat:js",  "jasmine", "cucumberjs", "plato" ]

  grunt.registerTask "javascript:dist", [ "coffee", "concat:js", "modernizr", "jasmine", "cucumberjs" ]

  # Production task
  grunt.registerTask "dev", [ "root-canal", "javascript:dev", "compass:dev", "concat:partials" ]

  grunt.registerTask "dist", [ "root-canal", "javascript:dist", "compass:dist", "concat:partials" ]

  # Default task
  grunt.registerTask "default", "dev"
