#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    watch:

      stylesheets:
        files: "sass/*"
        tasks: "compass"

      images:
        files: "img/*"
        tasks: "exec:img"

      templates:
        files: "templates/*"
        tasks: "templates"

      javascript:
        files: ["coffee/*", "js/*"]
        tasks: "javascript"

      jsTesting:
        files: ["src/**/*.js", "specs/**/*.js"]
        tasks: "jasmine"

    compass:
      dist:
        files:
          "dist/css/base.css": "sass/base.scss"

    coffee:
      compile:
        files:
          "js/app.js": "coffee/app.coffee"
      glob_to_multiple:
        files: grunt.file.expandMapping(["specs/*.coffee"], "specs/compiled/", {
          rename: (destBase, destPath) ->
            destBase + destPath.replace(/\.coffee$/, ".js").replace(/specs\//, "");
        })

    concat:
      home:
        src: ["templates/_header.html", "templates/_home-page.html", "tmp/_footer.html"]
        dest: "dist/index.html"

      about:
        src: ["templates/_header.html", "templates/_about-page.html", "tmp/_footer.html"]
        dest: "dist/about.html"

      fourohfour:
        src: "404.html"
        dest: "dist/404.html"

      js:
        #i.e. src: ["js/libs/mediaCheck.js", "js/app.js"],
        src: ["js/libs/*", "js/app.js"]

        #change this to a site specific name i.e. uwg.js or dty.js
        dest: "dist/js/<%= pkg.name %>.js"

    combine:
      html:
        input: "templates/_footer.html"
        output: "tmp/_footer.html"
        tokens: [
          token: "%1"
          string: "<%= pkg.name %>"
        ]

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

    clean: ["dist", "tmp"]

    styleguide:
      dist:
        files:
          "docs/scss": "sass/*.scss"

    exec:
      docco:
        command: "docco -o docs/js/ js/*.js js/*.coffee"
      img:
        command: "mkdir dist/img; cp -R img/ dist/img/"
      makeTmp:
        command: "mkdir tmp"

    jasmine:
      src: "dist/**/*.js"
      options:
        specs: "specs/compiled/*Spec.js"
        helpers: "specs/compiled/*Helper.js"

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
  grunt.loadNpmTasks "grunt-combine"

  # Default task.
  grunt.registerTask "templates", ["clean", "exec:makeTmp", "combine", "concat", "exec:img"]
  grunt.registerTask "javascript", ["coffee", "concat:js"]
  grunt.registerTask "prod", ["clean", "modernizr", "coffee", "compass", "exec:makeTmp", "combine", "concat", "exec:img"]
  grunt.registerTask "docs", ["styleguide", "exec:docco"]
  grunt.registerTask "default", ["coffee", "clean", "compass", "templates", "jasmine", "exec:img"]
