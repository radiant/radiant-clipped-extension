# Radiant Clipped Extension

[![Build Status](https://secure.travis-ci.org/radiant/radiant-clipped-extension.png)](http://travis-ci.org/radiant/radiant-clipped-extension)

Asset management for Radiant CMS.

The Clipped extension comes bundled with the Radiant gem but may be updated separately. Only Radiant versions 1.0 or newer are supported.

Please file bugs and feature requests on [Github][issues]. If you have questions regarding usage ask on the [mailing list][mailing-list].

[issues]: https://github.com/radiant/radiant-clipped-extension/issues
[mailing-list]: https://groups.google.com/forum/?hl=en#!forum/radiantcms

## Features

* Concurrent uploads
* Automatic thumbnail generation
  * requiers ImageMagick for images
  * requiers FFmpeg for videos
  * requiers Ghostscript for PDFs
* In-page and dedicated management interfaces
* Easily to extended with new asset types and processors

## Installation

If you installed the Radiant gem then you already have Clipped installed. You can upgrade to a newer version using `bundle update radiant-clipped-extension`.

Installation of the optional post-processors varies by system but are likely available through your package manager.

### Mac OSX

    brew install ghostscript imagemagick ffmpeg
    # or
    port install ghostscript imagemagick ffmpeg

### Debian

    apt-get install ghostscript imagemagick ffmpeg

### Windows

[Ghostscript][ghostscript], [ImageMagick][imagemagick] and [FFmpeg][ffmpeg] all
offer Windows installers that you can install in the usual way.

[ghostscript]: http://sourceforge.net/projects/ghostscript/
[imagemagick]: http://www.imagemagick.org/script/binary-releases.php
[ffmpeg]: http://ffmpeg.zeranoe.com/builds/

If the post-processors are not in your `PATH` or you're running Passenger you might need to set `Paperclip.options[:command_path]` to the location where the binaries are installed.

## Configuration

The clipped extension is configured in the usual way, but only its minor settings are exposed in the admin interface. The more architectural settings shouldn't be changed at runtime and some of them will require a lot of sorting out if they're changed at all, so those are only accessible through the console or by editing the database. Eventually they will be made part of the initial radiant installation process.

### Structural settings

* `paperclip.url` sets the url scheme for attached files. Paperclip interpolations are applied. You probably don't want to change this.
* `paperclip.path` sets the path scheme for attached files. Paperclip interpolations are applied. You might conceivably want to change this.
* `paperclip.additional_thumbnails` is a string of comma-separated style definitions that is passed to paperclip for any asset type that has a post-processor (that is, currently, images, pdfs and video clips). The definitions are in the format name=geometry and when assembled the string will look something like `preview=640x640>,square=#260x260`. Thumbnail and icon styles are already defined and don't need to be configured this way.
* `paperclip.storage` can be 'filesystem' (the default) or 'fog' for cloud storage (such as s3).
* `paperclip.skip_filetype_validation` is true by default and allows uploads of any mime type.

### Cloud Storage

Set `paperclip.storage` to 'fog' and add the following line to your `Gemfile`

`gem "fog", "~> 1.0"`

You also have to provide the following settings:

* `paperclip.fog.provider` # set to one of "AWS", "Google" or "Rackspace"

If set to AWS, provide the following:

* `paperclip.s3.bucket`
* `paperclip.s3.key`
* `paperclip.s3.secret`
* `paperclip.s3.region`

If set to "Google", provide the following:

* `paperclip.fog.directory`
* `paperclip.google_storage.access_key_id`
* `paperclip.google_storage.secret_access_key`

If set to "Rackspace", provide the following:

* `paperclip.fog.directory`
* `paperclip.rackspace.username`
* `paperclip.rackspace.api_key`

And optionally:

* `paperclip.fog.host`
* `paperclip.fog.public?`

### Configurable settings

If you want to disable a whole category of post-processing, set one of these options to false:

* `assets.create_image_thumbnails?`
* `assets.create_video_thumbnails?`
* `assets.create_pdf_thumbnails?`

If we can't find ffmpeg on initialization, video thumbnailing will be disabled automatically by setting `assets.create_video_thumbnails?` to false.

To set a threshold for the size of uploads permitted:

* `assets.max_asset_size` which should be an integer number of MB

And you can set some defaults:

* `assets.insertion_size` is the name of the style that's used when you click on 'insert' to add a radius asset tag to your text. You can edit it after insertion, of course.
* `assets.display_size` is the name of the style that's shows when you edit a single asset in the admin interface.

## Usage

For most purposes you will probably work with assets while you're working on pages. Click on one of the 'assets' links and a panel will pop up allowing you to find, insert and attach existing assets or upload new ones.

For tidying up, replacing files and other admin, click on the 'assets' tab to get a larger version of the same list. Here again you can search for assets and filter the results by type, but the options are 'edit' and 'remove' and on editing you can change name, file and caption while keeping page associations intact.

## Radius Tags

The asset manager has its own family of radius tags. The basic tag is `<r:asset/>`, which can be used either alone or as a double tag. This tag requires a `name` or `id` attribute, which references the asset. The `<r:asset/>` tag can be combined with other tags for a variety of uses:

    <r:asset:image name="image.png"/>  #=>  <img src="/path/to/image.png" />
    <r:asset:link name="image.png"/>   #=>  <a href="/path/to/image.png">image.png</a>

You could also use:

    <r:asset:link name="bar.pdf">Download PDF</r:asset:link>

Asset links are also available, such as content_type, file_size, and url.

Another important tag is the `<r:assets:each>...</r:assets:each>` (note the plural namespace tag "assets"). If a page has attached assets, the `<r:assets:each>` tag will cycle through each asset. You can then use an image, `link` or `url` tag to display and connect your assets. Usage:

    <r:assets:each [limit=0] [offset=0] [order="asc|desc"] [by="position|title|..."]>
      ...
    </r:assets:each>

This tag uses the following parameters:

* `limit` and `offset` let you specify a range of assets
* `order` and `by` lets you control sorting

The conditional tags `<r:if_assets [min_count="0"]>` and `<r:unless_assets [min_count="0"]>` allow you to optionally render content based on the existence of tags. They accept the same options as `<r:assets:each>`.

Thumbnails are automatically generated for images when the images are uploaded. By default, two sizes are made for use within the extension itself. These are "icon" 42px by 42px and "thumbnail" which is 100px square.

You can access sizes of image assets for various versions with tags like `<r:asset:width [size="original"]/>` and `<r:asset:height [size="original"]/>`.

Also, for vertical centering of images, you have the handy `<r:asset:top_padding container="<container height>" [size="icon"]/>` tag. Working example:

    <ul>
      <r:assets:each>
        <li style="height:140px">
          <img style="padding-top:<r:top_padding size='category' container='140'/>px" src="<r:url/>" alt="<r:caption/>">
        </li>
      </r:assets:each>
    </ul>

## Contributions

If you would like to contribute, please [fork the project][fork] and submit a [pull request][pull-request].

[fork]: http://help.github.com/fork-a-repo/
[pull-request]: http://help.github.com/send-pull-requests/

Pull requests with working tests are preferred and have a greater chance of being merged.

## TODO

* Progress bars while uploading assets
* Warning if you try and save a page while assets are still uploading
* Radius tags for the HTML video and audio elements
* Auxiliary extension to add video transcoding support

## Authors

* Keith Bingman
* John Long
* William Ross

Copyright 2011 the Radiant team. Released under the same terms as Radiant.
