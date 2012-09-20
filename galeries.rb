module Jekyll

  class Gallery
    include Comparable
    MATCHER = /^(\d+-\d+-\d+)-(.*)$/
    
    attr_reader :date, :name, :photos
    
    def self.valid?(dir)
      matches = File.basename(dir) =~ MATCHER
      not_empty = !(Dir["#{dir}/*.{jpg,JPG, Jpg}"]).empty?
      
      matches && not_empty
    end
    
    def initialize(base, dir)
    
      dirname = File.basename(dir)
    
      m, @date, @name = *dirname.match(MATCHER)
      
      photo_files = Dir["#{dir}/*.{jpg,JPG, Jpg}"]
      photo_files.sort!
      
      @photos = photo_files.map do |p| 
        img = File.basename p
        {'alt' => img,
         'link_to' => "#{base}/#{dirname}/#{img}",
         'img_src' => "#{base}/#{dirname}/thumbs/#{img}",
         'caption' => ''
        } 
      end
    end
    
    def <=>(other)
      @date <=> other.date
    end
    
    def page(site, base, dir)
      GalleryPage.new(site, base, dir, @name, @date, @photos)
    end
    
  end

  class GalleryPage < Page
    def initialize(site, base, dir, title, date, photos)
      @site = site
      @base = base
      @dir = dir
      @name = "#{date}-#{title}.html"

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'gallery.html')
      self.data['photos'] = photos
      self.data['title'] = title
      self.data['date'] = date
    end
  end

  class GalleryIndex < Page
    def initialize(site, base, dir, galleries)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'gallery_index.html')
      self.data['title'] = "Gallery"
      self.data['photos'] = galleries
    end
  end

  class GalleryPageGenerator < Generator
    safe false
    
    def generate(site)
      if site.layouts.key? 'gallery_index'
        dir = site.config['photos_path']
        if (File.directory? dir)
	      make_galleries(site, dir)
        end
      end
    end
    
    def make_galleries(site, dir)
      galleries = []
      Dir["#{dir}/*"].each do |d|
	    if (Gallery.valid? d)
	      galleries << Gallery.new(site.config['photos_url'], d)
	    end
	  end
	  
	  galleries.sort!
      
      index = galleries.map do |g|
        gallery_page = g.page(site, site.source, site.config['gallery_url'])
        site.pages << gallery_page
        {'alt' => g.name,
            'caption' => g.name,
            'link_to' => gallery_page.name, 
            'img_src' => g.photos[0]['img_src']}
      end
      
      site.pages << GalleryIndex.new(site, site.source, site.config['gallery_url'], index)
      
    end
    
  end

end
