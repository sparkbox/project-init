# grunt-targethtml

Produces html-output depending on grunt target

## Getting Started
Install this grunt plugin next to your project's [grunt.js gruntfile][getting_started] with: `npm install grunt-targethtml`

Then add this line to your project's `grunt.js` gruntfile:

```javascript
grunt.loadNpmTasks('grunt-targethtml');
```

[grunt]: https://github.com/cowboy/grunt
[getting_started]: https://github.com/cowboy/grunt/blob/master/docs/getting_started.md

## Documentation

Use conditional statements in your html based on grunt targets like:

```html
<!--(if target release)><link rel="stylesheet" type="text/css" href="styles.css" /><!(endif)-->
<!--(if target debug)><!--><link rel="stylesheet/less" type="text/css" href="styles.less">
<script type="text/javascript">var less = { env: 'development' };</script>
<script src="libs/less.js" type="text/javascript"></script><!--<!(endif)-->
```

Or

```html
<!--(if target release)><script data-main="app/main" src="require.js"></script><!(endif)-->
<!--(if target debug)><script data-main="app/main" src="require.js"></script><!(endif)-->
<!--(if target dummy)><!--><script data-main="app/main" src="libs/require.js"></script><!--<!(endif)-->
```

In here the dummy entry will never be outputed after grunt, but this line will work when the HTML is not being parsed (in development-setup).

You could use the [if...] notation like we're used from the [if lt IE 9], but ironically that fails in IE.

Configure which files to be outputted in your `initConfig`:

```javascript
grunt.initConfig({
  // ... other configs

  // produce html
  targethtml: {
    debug: {
      src: 'public/index.html',
      dest: 'public/dist/debug/index.html'
    },
    release: {
      src: 'public/index.html',
      dest: 'public/dist/release/index.html'
    }
  },

  // ... other configs
});
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [grunt][grunt].

## Release History
* 8/31/12 - v0.1.0 - Initial release.
* 9/1/12 - v0.1.1 - Fixed naming issues
* 9/7/12 - v0.1.2 - Accept round braces in if statements for IE support
* 10/14/12 - v0.1.3 - Adjustments towards grunt file api

## License
Copyright (c) 2012 Ruben Stolk
Licensed under the MIT license.
