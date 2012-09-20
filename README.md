# Jekyll Plugins

Here are couple of plugins that I've wrote for myself. You'll probably want to
tweak them according to your needs before usage.

## Categories

Each category is treated more or less as a separate blog. Archive pages and
tags are per category.

I've configured Jekyll's permalink as `/:categories/:year/:month/:title.html`
so categories are named url-friendly (smallcase, no spaces etc.). Tags are on
the other hand free form, so I mangle tag names to form urls.

### Usage

Generator won't run unless there is layout named `categories`, which is also
a default layout that will be used if there is no layout named same as category.

Titles for category pages are read from config. For each category, key `#{category}_title`
is used. 

### TODO

Pagination

## Gallery

Gallery plugin generates gallery pages from image folders.

### Usage

Example directory structure:

* photos
    * 2012-07-25-Summer Vacation
        * thumbs
            * image1.jpg
        * image1.jpg
    * 2012-09-10-Birthday Party
        * thumbs
            * image2.jpg
        * image2.jpg

Only config parameter is file system path to images direstory.


