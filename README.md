# Assets Plugin for [DocPad](http://docpad.org)

Change URL of asset files to contain hash of contents, allowing for effective caching whilst enabling cache busting when contents change.

This plugin enables the function `@asset()`, which takes a single string argument of the asset to manage.  For example, if you have some HTML which looks like this:

    <img src="/images/myimage.png" />

Then to put the asset under then plugin's control you would change this to:

    <img src="<%- @asset('/images/myimage.png') %>" />

And that's it!

By default the plugin will leave the path along and replace the name of the file with it's hash.  Continuing on from the above example, with the defaults the output URL will be something like `/images/3992a5c4177710abf7d1e90b91636b26cbac138b.png`.  There are two options which you can tweak to change this default output.

  - `retainPath`: if set to 'no' then this will remove any leading path from the URL and put the asset in the root directory.  In the above case the output URL will be `/3992a5c4177710abf7d1e90b91636b26cbac138b.png`
  - `retainName`: if set to 'yes' then this will retain the name of the original file, and append the hash to it.  In the above case the output URL will be `/images/myimage-3992a5c4177710abf7d1e90b91636b26cbac138b.png`

## Implementation Notes
Please ensure that all assets use absolute path names, otherwise this plugin might not operate correctly.

## Install

```
npm install --save docpad-plugin-assets
```



## History
You can discover the history inside the `History.md` file

## License
Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT License](http://creativecommons.org/licenses/MIT/)
<br/>Copyright &copy; 2013 Jim McDonald
