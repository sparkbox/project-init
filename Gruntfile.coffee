#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    watch:

      stylesheets:
        files: "scss/*"
        tasks: "compass:dev"

      images:
        files: "images/*"
        tasks: "copy:main"

      partials:
        files: "partials/*"
        tasks: "partials"

      javascript:
        files: ["coffee/*", "js/libs/*.js"]
        tasks: "javascript:dev"

      jsTesting:
        files: "dist/js/*.js"
        tasks: "jasmine"

      cukes:
        files: ["features/*.feature", "features/step_definitions/*.coffee"]
        tasks: "cucumberjs"

      rootDirectory:
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
          "dist/about.html": ["partials/_header.html", "partials/_about-page.html", "partials/_footer.html"]
          "dist/404.html": "partials/404.html"
      js:
        #first concatenate libraries, then our own JS
        src: ["js/concat/*", "js/app.js"]
        #put it in dist/
        dest: "dist/js/<%= pkg.name %>.js"

    modernizr:
      devFile: "js/no-concat/modernizr.js"
      outputFile: "dist/js/modernizr.js"
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

    jasmine:
      src: "dist/**/*.js"
      options:
        specs: "specs/js/*Spec.js"
        helpers: "specs/js/*Helper.js"
        vendor: ["js/concat/jquery-1.9.1.min.js", "specs/lib/*.js"]

    cucumberjs: {
      files: 'features',
      options: {
        steps: "features/step_definitions"
      }
    }

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

  # NOTE: this has to wipe out everything
  grunt.registerTask "root-canal", [ "clean:all", "copy:main" ]

  # Clean, compile and concatenate JS
  grunt.registerTask "javascript:dev", [ "coffee", "concat:js",  "jasmine", "cucumberjs", "plato" ]

  grunt.registerTask "javascript:dist", [ "coffee", "modernizr", "jasmine", "cucumberjs" ]

  # Production task
  grunt.registerTask "dev", [ "root-canal", "javascript:dev", "compass:dev", "concat:partials" ]

  grunt.registerTask "dist", [ "root-canal", "javascript:dist", "compass:dist", "concat:partials" ]

  # Default task
  grunt.registerTask "default", "dev"
