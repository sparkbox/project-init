#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    watch:

      stylesheets:
        files: "scss/*"
        tasks: "compass"

      images:
        files: "images/*"
        tasks: "images"

      partials:
        files: "partials/*"
        tasks: "partials"

      javascript:
        files: ["coffee/*", "js/libs/*.js"]
        tasks: "javascript"

      jsTesting:
        files: ["src/**/*.js", "specs/**/*.js"]
        tasks: "jasmine"

      rootDirectory:
        files: [ "root-directory/**/*", "root-directory/.*" ]
        tasks: "default"

    compass:
      dist:
        files:
          "dist/css/base.css": "scss/base.scss"

    coffee:
      compile:
        files:
          "js/app.js": "coffee/app.coffee"
      glob_to_multiple:
        files: grunt.file.expandMapping(["specs/*.coffee"], "specs/js/", {
          rename: (destBase, destPath) ->
            destBase + destPath.replace(/\.coffee$/, ".js").replace(/specs\//, "");
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
        #i.e. src: ["js/libs/mediaCheck.js", "js/app.js"],
        src: ["js/libs/*", "js/app.js"]
        #change this to a site specific name i.e. uwg.js or dty.js
        dest: "dist/js/<%= pkg.name %>.js"

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

    clean:
      all:
        src: "dist/*"
        dot: true # clean hidden files as well
      partials: "dist/*.html"
      stylesheets: "dist/css/*"
      javascript: "dist/js/*"
      images: "dist/images/*"

    styleguide:
      dist:
        files:
          "docs/scss": "scss/*.scss"

    exec:
      docco:
        command: "docco -o docs/js/ js/*.js js/*.coffee"
      copyImages:
        command: "mkdir -p dist/images; cp -R images/ dist/images/"
      copyRootDirectory:
        command: "cp -Rp root-directory/ dist/"

    jasmine:
      src: "dist/**/*.js"
      options:
        specs: "specs/js/*Spec.js"
        helpers: "specs/js/*Helper.js"
        vendor: ["js/libs/jquery-1.9.0.min.js", "specs/lib/*.js"]

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-compass"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-jasmine"
  grunt.loadNpmTasks "grunt-modernizr"
  grunt.loadNpmTasks "grunt-notify"
  grunt.loadNpmTasks "grunt-styleguide"
  grunt.loadNpmTasks "grunt-exec"

  # Clean and concatenate partials
  grunt.registerTask "partials", [ "clean:partials", "concat:partials" ]

  # Clean, compile and concatenate JS
  grunt.registerTask "javascript", [ "clean:javascript", "coffee", "concat:js", "jasmine" ]

  # Clean and compile stylesheets
  grunt.registerTask "stylesheets", ["clean:stylesheets", "compass"]

  # Clean and copy images
  grunt.registerTask "images", [ "clean:images", "exec:copyImages" ]

  # Clean dist/ and copy root-directory/
  # NOTE: this has to wipe out everything
  grunt.registerTask "root-canal", [ "clean:all", "exec:copyRootDirectory" ]

  # Generate documentation
  grunt.registerTask "docs", [ "styleguide", "exec:docco" ]

  # Production task
  grunt.registerTask "prod", [ "modernizr", "default" ]

  # Default task
  grunt.registerTask "default", [ "root-canal", "partials", "javascript", "stylesheets", "images" ]
