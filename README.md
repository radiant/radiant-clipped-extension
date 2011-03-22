Radiant Assets Extension
------------------------

Based on Keith Bingman's excellent Paperclipped extension for Radiant. This
extension provides Mephisto-style asset management for Radiant. Complete with
an asset bucket and easy upload functionality.

This extension is an experimental extension designed for Radiant version 1.0
or higher. The goal is that it will be a drop-in replacement for both
Paperclipped and Page Attachments.


## Installation

To install the Radiant Assets extension, just run:
 
    rake production db:migrate:extensions
    rake production radiant:extensions:assets:update

This runs the database migrations and installs the javascripts, images, and
CSS.


## Configuration

TODO: Remove references to Settings extension

If you install the Settings Extension (highly recommended), you can also
easily adjust both the sizes of any additional thumbnails and which thumbnails
are displayed in the image edit view. The default is the original file, but
any image size can be used by giving in the name of that size.

If you do install the Settings Extension you should be sure to add a
config.extensions line to your environment.rb file:

    config.extensions = [ :settings, :all ]
    
Also the Settings Extension migration should be run before Paperclipped's
migration.

The configuration settings also enable a list of the allowed file types,
maximum file size and should you need it, the path to your installation of
Image Magick (this should not be needed, but I sometimes had a problem when
using mod_rails).

Paperclipped will integrate with the Styles'n'Scripts extension. For that to
work, you'll need to load that extension before the assets extension:

    config.extensions = [ :sns, :all ]


## Usage

Once installed, you get a new Tab with the entire assets library and a search.
You can also easily attach assets to any page and directly upload them to a
page.


## Tags

The Radiant assets extension adds a variety of new tags. The basic tag is the
<code><r:asset /></code> tag, which can be used either alone or as a double
tag. This tag requires the "name" attribute, which references the asset. If
you use the drag and drop from the asset bucket, this name will be added for
you. The <code><r:asset /></code> tag can be combined with other tags for a
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

    <r:assets:each [limit=0] [offset=0] [order="asc|desc"] [by="position|title|..."] [extensions="png|pdf|doc"]>
      ...
    </r:assets:each>

This tag uses the following parameters:

* `limit` and `offset` let you specify a range of assets
* `order` and `by` lets you control sorting
* `extensions` allows you to filter assets by file extensions; you can specify multiple extensions separated by `|`

The conditional tags <code><r:if_assets [min_count="0"]></code> and
<code><r:unless_assets [min_count="0"]></code> allow you to optionally render
content based on the existence of tags. They accept the same options as
`<r:assets:each>`.

Thumbnails are automatically generated for images when the images are
uploaded. By default, two sizes are made for use within the extension itself.
These are "icon" 42px by 42px and "thumbnail" which is fit into 100px,
maintaining its aspect ratio.

You can access sizes of image assets for various versions with the tags
`<r:asset:width [size="original"]/>` and `<r:asset:height
[size="original"]/>`.

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


## Using Amazon S3

First, be sure you have the aws\-s3 gem installed. 

    gem install aws-s3

Everything works as before, but now if you want to add S3 support, you simply
set the storage setting to "s3". 

    Radiant::Config[assets.storage] = "s3"
 
Then add 3 new settings with your Amazon credentials, either in the console or
with the [Settings](http://github.com/Squeegy/radiant-settings/tree/master)
extension:

<pre><code>Radiant::Config[assets.s3.bucket] = "my_supercool_bucket"
Radiant::Config[assets.s3.key] = "123456"
Radiant::Config[assets.s3.secret] = "123456789ABCDEF"
</code></pre>

And finally the path you want to use within your bucket, which uses the same
notation as the Paperclip plugin.

Radiant::Config[assets.path] = ":class/:id/:basename_:style.:extension"

The path setting, along with a new <code>url</code> setting can be used with
the file system to customize both the path and url of your assets.


## Migrating from Paperclipped

TODO: Add instructions for migrating from Paperclipped

This extension is based on Keith Bingman's original Paperclipped extension so
the upgrade path is very simple. You just need to run the appropriate Rake
task...


## Migrating from Page Attachments

If you're moving from Page Attachments to this extension, here's how to
migrate smoothly:

TODO: Tweak instructions for migrating from Page Attachments. Remove references to the Ray extension

First, remove or disable the page_attachments extension, and install the
new assets extension:

<pre><code>rake ray:dis name=page_attachments
rake ray:assets
</code></pre>

The migration has now copied your original `page_attachments` table to `old_page_attachments`.

<pre><code>rake radiant:extensions:assets:migrate_from_page_attachments
</code></pre>

This rake task will create new attachments for all `OldPageAttachments`. It
will also ask you if you want to clean up the old table and thumbnails in
`/public/page_attachments`.


## Contributions

This extension is a work in progress. If you would like to
contribute, please fork the project and submit a pull request:

<https://github.com/radiant/radiant-assets-extension>

Pull requests with working tests are preferred and have a greater chance of
being merged.


## Support

If you have questions about this extension please post a message to the
Radiant-Dev mailing list:

<http://groups.google.com/group/radiantcms-dev>

If you would like to file a bug report or feature request, please create a
GitHub issue here:

<https://github.com/radiant/radiant-assets-extension/issues>