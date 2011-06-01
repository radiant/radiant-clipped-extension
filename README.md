Radiant Clipped Extension
------------------------

This is a new core extension intended for use with Radiant version 1.0 or higher. 
It is based on Keith Bingman's excellent Paperclipped extension, for which it is a drop-in replacement. 
It should also be an easy upgrade from `page_attachments`, but I haven't tested that yet.

## Changes

* video files frame-grabbed (automatically disabled if FFmpeg is not found)
* pdfs thumbnailed
* new asset-retrieval and page-attachment interface (by John Long)
* new inline upload mechanism that allows several concurrent uploads and attachment to new pages
* easily extended with new asset types and processors
* helpful insert buttons that do the right thing.

## Still to do

* progress bars on uploading assets
* warning if you try and save a page while assets are still uploading
* html5 video and audio tags in radius (with sensible flash fallbacks)

Video transcoding support will be in an optional extension with `delayed_job` support.

# Known bugs

At the moment I think uploads probably don't work in IE7. See github for more issues.

## Requirements

The `paperclip`, `uuidtools` and `acts_as_list` gems are required. For S3 storage you need the `aws-s3` gem.

Paperclip's post-processors require ImageMagick. PDF-thumbnailing also requires ghostscript, which is usually 
installed with ImageMagick anyway, and if you want to generate thumbnails from video clips then you also need FFmpeg. 

On unixy systems there should be packages available to satisfy all these requirements. You don't need to 
install development libraries, but you will get a lot of little file-type utilities if you don't have them already.

On OS X, with macports:

    port install ghostscript imagemagick ffmpeg

On debian-like systems:

    apt-get install ghostscript imagemagick ffmpeg

And I expect it's very similar with yum.

On Windows, you can get binary installers of all the required pieces and apparently these days they're simple 
to install and connect:

* ImageMagick: http://www.imagemagick.org/script/binary-releases.php
* Ghostscript: http://sourceforge.net/projects/ghostscript/
* FFMpeg: http://ffmpeg.zeranoe.com/builds/

If your paths are strange, or you're running under passenger, you may need to set `Paperclip.options[:command_path]` 
to the location of these binaries for each of your environments. On OS X that's usually `/opt/local/bin`.

## Installation

This extension is not currently compatible with versions of radiant earlier than 1.0rc. The incompatibilities 
are fairly minor and it may be backported, but for now if you're running a version of radiant which with the assets 
extension will work, you will find it is already installed. If you don't have it in your radiant distribution, it 
probably wouldn't work anyway.

## Upgrading from paperclipped

No special steps are required. Paperclipped migrations are respected. The /images/assets directory is no longer needed. 
and can be deleted. See below for some radius tag changes that won't affect you yet but should be borne in mind.

## Upgrading from page_attachments

This is supposed to be straightforward too. In theory once the clipped extension has been migrated all you need is:

    rake radiant:extensions:clipped:migrate_from_page_attachments

But I haven't tested that theory recently.

## Radius tag changes

The full radius tag set of paperclipped is still supported, so your pages should just work. If they worked before. 

The preferred syntax is slightly different, though. Where paperlipped used the `r:assets` namespace for everything, the 
assets extension has adopted a readable system of singular and plural tags that will be familiar from other bits of radiant:

    <r:assets:each>
      <a href="<r:asset:url size="download" />">
        <r:asset:image size="thumbnail" />
      </a>
      <span class="caption"><r:asset:caption /></span>
    </r:assets:each>

Anything to do with the collection of assets is plural. Anything to do with a particular asset is singular. The old plural 
forms still work but they are deprecated and (as the log messages will keep telling you) likely to removed in version 2.

## Configuration

The clipped extension is configured in the usual way, but only its minor settings are exposed in the admin interface. The
more architectural settings shouldn't be changed at runtime and some of them will require a lot of sorting out if they're 
changed at all, so those are only accessible through the console or by editing the database. Eventually they will be made 
part of the initial radiant installation process.

### Structural settings

* `clipped.url` sets the url scheme for attached files. Paperclip interpolations are applied. You probably don't want to change this.
* `clipped.path` sets the path scheme for attached files. Paperclip interpolations are applied. You might conceivably want to change this.
* `clipped.additional_thumbnails` is a string of comma-separated style definitions that is passed to paperclip for any asset type that has a post-processor (that is, currently, images, pdfs and video clips). The definitions are in the format name=geometry and when assembled the string will look something like `preview=640x640>,square=#260x260`. Thumbnail and icon styles are already defined and don't need to be configured this way.
* `clipped.storage` can be 'filesystem' (the default) or 's3' for amazon's cloud service.
* `clipped.skip_filetype_validation` is true by default and allows uploads of any mime type.

If the storage option is set to 's3' then these settings are also required:

* `clipped.s3.bucket`
* `clipped.s3.key`
* `clipped.s3.secret`

And optionally:

* `clipped.s3.host_alias`

### Configurable settings

If you want to disable a whole category of post-processing, set one of these options to false:

* `clipped.create_image_thumbnails?`
* `clipped.create_video_thumbnails?`
* `clipped.create_pdf_thumbnails?`

If we can't find ffmpeg on initialization, video thumbnailing will be disabled automatically by setting `clipped.create_video_thumbnails?` to false.

To set a threshold for the size of uploads permitted:

* `assets.max_asset_size` which should be an integer number of MB

And you can set some defaults:

* `assets.insertion_size` is the name of the style that's used when you click on 'insert' to add a radius asset tag to your text. You can edit it after insertion, of course.
* `assets.display_size` is the name of the style that's shows when you edit a single asset in the admin interface.

## Usage

For most purposes you will probably work with assets while you're working on pages. Click on one of the 'assets' links and a panel will pop up allowing you to find, insert and attach existing assets or upload new ones. 

For tidying up, replacing files and other admin, click on the 'assets' tab to get a larger version of the same list. Here again you can search for assets and filter the results by type, but the options are 'edit' and 'remove' and on editing you can change name, file and caption while keeping page associations intact.

## Radius Tags

The asset manager has its own family of radius tags. The basic tag is <code><r:asset /></code>, 
which can be used either alone or as a double tag. This tag requires a `name` or `id` attribute, 
which references the asset. The <code><r:asset /></code> tag can be combined with other tags for a
variety of uses:

    <r:asset:image name="image.png" />  #=>  <img src="/path/to/image.png" />
    <r:asset:link name="image.png" />   #=>  <a href="/path/to/image.png">image.png</a>

You could also use: 

    <r:asset:link name="bar.pdf">Download PDF</r:asset:link>

Asset links are also available, such as content_type, file_size, and url. 

Another important tag is the <code><r:assets:each>...</r:assets:each></code>.
(Note the plural namespace tag "assets".) If a page has attached assets, the
assets:each tag will cycle through each asset. You can then use an image,
link or url tag to display and connect your assets. Usage:

    <r:assets:each [limit=0] [offset=0] [order="asc|desc"] [by="position|title|..."]>
      ...
    </r:assets:each>

This tag uses the following parameters:

* `limit` and `offset` let you specify a range of assets
* `order` and `by` lets you control sorting

The conditional tags <code><r:if_assets [min_count="0"]></code> and
<code><r:unless_assets [min_count="0"]></code> allow you to optionally render
content based on the existence of tags. They accept the same options as
`<r:assets:each>`.

Thumbnails are automatically generated for images when the images are
uploaded. By default, two sizes are made for use within the extension itself.
These are "icon" 42px by 42px and "thumbnail" which is 100px square.

You can access sizes of image assets for various versions with tags like
`<r:asset:width [size="original"]/>` and <code><r:asset:height
[size="original"]/></code>.

Also, for vertical centering of images, you have the handy
`<r:asset:top_padding container="<container height>" [size="icon"]/>` tag.
Working example:

    <ul>
      <r:assets:each>
        <li style="height:140px">
          <img style="padding-top:<r:top_padding size='category' container='140' />px" 
               src="<r:url />" alt="<r:title />" />
        </li>
      </r:assets:each>
    </ul>

## Contributions

This extension is a work in progress. If you would like to
contribute, please fork the project and submit a pull request:

<https://github.com/radiant/radiant-clipped-extension>

Pull requests with working tests are preferred and have a greater chance of
being merged.

## Support

If you have questions about this extension please post a message to the
Radiant-Dev mailing list:

<http://groups.google.com/group/radiantcms-dev>

If you would like to file a bug report or feature request, please create a
GitHub issue here:

<https://github.com/radiant/radiant-clipped-extension/issues>

## Authors

* Keith Bingman
* John Long
* William Ross

Copyright 2011 the radiant team. Released under the same terms as radiant.
