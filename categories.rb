module Jekyll

    class CategoryPage < Page
        def initialize(params = {})
            @site = params[:site]
            @base = params[:base]
            @dir = params[:dir]
            @name = params[:name]

			puts "Adding page #{@dir}/#{@name}"

            self.process(@name)
            self.read_yaml(File.join(@base, '_layouts'), "#{params[:layout]}.html")
            self.data['title'] = params[:title]
            self.data['posts'] = params[:posts]
            self.data['pagination'] = params[:pagination]
            self.data['category'] = params[:category]
        end
    end

    class CategoryPages

        def initialize(name)
            @name = name
            @posts = []
            @tags = Hash.new{|hash, key| hash[key] = []}
            @archive = Hash.new{|hash, key| hash[key] = []} 
        end

        def <<(post)
            @posts << post
            post.tags.each {|tag| @tags[tag] << post}
            @archive[post.date.year] << post
        end

        def pages(site, base)
            ret = []
            layout = (site.layouts.key? @name)? @name : 'category'

            @tags.each do |tag, posts|
                name = "#{tag.downcase.tr(' ', '-').delete('&', '?', '/', '=', '%')}.html"
                params = {site: site, base: base, category: @name,
					dir: "#{@name}/tag", layout: layout,
					name: name, title: tag, 
					posts: posts, pagination: {}}
                ret << CategoryPage.new(params)
            end
            
            @archive.each do |year, posts|
                params = {site: site, base: base, category: @name,
					dir: "#{@name}/#{year}", layout: layout,
					name: 'index.html', title: year, 
					posts: posts, pagination: {}}
                ret << CategoryPage.new(params)
			end

            title = site.config["#{@name}_title"] || @name
            params = {site: site, base: base, category: @name,
				dir: @name, layout: layout, 
                name: 'index.html', title: title, 
                posts: @posts.reverse, pagination: {}}
            ret << CategoryPage.new(params)

            ret
        end
    end

    class CategoryPageGenerator < Generator
        safe true

        def generate(site)
            if site.layouts.key? 'category'
                categories = Hash.new{|hash, key| hash[key] = CategoryPages.new(key)}
                site.posts.each do |post|
                    post.categories.each {|category| categories[category] << post}
                end
                categories.each_value do |category|
                    category.pages(site, site.source).each {|page| site.pages << page}
                end
            end
        end
    end

end
