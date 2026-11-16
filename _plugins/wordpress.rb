# Rebuilds the WordPress pieces of levees.org that a plain Jekyll site lacks:
#   * archive pages with WordPress's URLs and three posts per page
#     (/blog/, /category/<slug>/, /tag/<slug>/, /YYYY/, /YYYY/MM/, /YYYY/MM/DD/,
#     each with /page/N/ after the first page);
#   * Liquid filters for WordPress's date formats.
#
# The page markup lives in _layouts/archive.html; this file only decides which
# posts go on which page and what the page is called.

module LeveesOrg
  PER_PAGE = 3
  SITE_NAME = "Levees.Org".freeze
  TAGLINE = "Your source for information on levee and flood protection nationwide.".freeze

  class ArchiveGenerator < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
      posts = site.posts.docs.sort_by { |p| [-p.date.to_i, -(p.data["wp_id"] || 0)] }

      paginate(site, "/blog/", posts,
               "archive_type" => "blog", "archive_name" => "Blog",
               "body_base" => ["blog"])

      (site.data["categories"] || {}).each do |slug, cat|
        list = posts.select { |p| Array(p.data["categories"]).include?(slug) }
        next if list.empty?
        paginate(site, "/category/#{slug}/", list,
                 "archive_type" => "category", "archive_name" => cat["name"],
                 "body_base" => ["archive", "category", "category-#{slug}", "category-#{cat['id']}"],
                 "paged_class" => "category-paged")
      end

      (site.data["tags"] || {}).each do |slug, tag|
        list = posts.select { |p| Array(p.data["tags"]).include?(slug) }
        next if list.empty?
        paginate(site, "/tag/#{slug}/", list,
                 "archive_type" => "tag", "archive_name" => tag["name"],
                 "body_base" => ["archive", "tag", "tag-#{slug}", "tag-#{tag['id']}"],
                 "paged_class" => "tag-paged")
      end

      date_base = { "archive_type" => "date", "body_base" => ["archive", "date"], "paged_class" => "date-paged" }
      posts.group_by { |p| p.date.strftime("%Y") }.each do |y, list|
        paginate(site, "/#{y}/", list, date_base.merge("archive_name" => y))
      end
      posts.group_by { |p| p.date.strftime("%Y/%m") }.each do |ym, list|
        paginate(site, "/#{ym}/", list, date_base.merge("archive_name" => list.first.date.strftime("%B, %Y")))
      end
      posts.group_by { |p| p.date.strftime("%Y/%m/%d") }.each do |ymd, list|
        d = list.first.date
        paginate(site, "/#{ymd}/", list, date_base.merge("archive_name" => "#{d.strftime('%A, %B')} #{d.day}, #{d.year}"))
      end
    end

    private

    def paginate(site, base, list, info)
      pages = list.each_slice(PER_PAGE).to_a
      total = pages.size
      pages.each_with_index do |chunk, i|
        n = i + 1
        dir = n == 1 ? base : "#{base}page/#{n}/"
        page = Jekyll::PageWithoutAFile.new(site, site.source, dir, "index.html")
        body = info["body_base"].dup
        if n > 1
          # WordPress's order: "blog paged", "archive paged category", but "archive date paged".
          body.insert(info["archive_type"] == "date" ? 2 : 1, "paged")
          body << "paged-#{n}"
          body << "#{info['paged_class']}-#{n}" if info["paged_class"]
        end
        body << "wp-theme-levees2023"
        name = info["archive_name"]
        part = n > 1 ? " - Part #{n}" : ""
        theme_title = "#{name} | #{SITE_NAME}#{part}#{SITE_NAME}"
        theme_title += " | #{TAGLINE}" if info["archive_type"] == "blog"
        theme_title += " | Page #{n}" if n > 1
        page.data.merge!(
          "layout" => "archive",
          "archive_type" => info["archive_type"],
          "archive_name" => name,
          "paged_posts" => chunk,
          "page_num" => n,
          "total_pages" => total,
          "base_url" => base,
          "older_url" => n < total ? "#{base}page/#{n + 1}/" : nil,
          "newer_url" => n > 1 ? (n == 2 ? base : "#{base}page/#{n - 1}/") : nil,
          "body_class" => body.join(" "),
          "theme_title" => theme_title,
          "seo_title" => "#{name} | #{SITE_NAME}#{part}",
          "canonical" => info["archive_type"] == "blog" ? base : dir,
          "robots" => n > 1 && info["archive_type"] == "blog" ? "noindex, nofollow, max-image-preview:large" : "max-image-preview:large",
          "sitemap" => n == 1
        )
        site.pages << page
      end
    end
  end

  module Filters
    # "Tuesday, July 21st, 2026" (the theme's entry-meta date)
    def wp_long_date(input)
      t = Jekyll::Utils.parse_date(input.to_s) rescue input
      t = input if input.respond_to?(:strftime)
      "#{t.strftime('%A, %B')} #{ordinal(t.day)}, #{t.year}"
    end

    # "Monday, August 24, 2009 at 8:14 pm" (comment timestamps)
    def wp_comment_date(input)
      t = input.respond_to?(:strftime) ? input : Time.parse(input.to_s)
      "#{t.strftime('%A, %B')} #{t.day}, #{t.year} at #{t.strftime('%-l:%M')} #{t.strftime('%P')}"
    end

    # "July 21, 2026" (home page news list)
    def wp_short_date(input)
      t = input.respond_to?(:strftime) ? input : Time.parse(input.to_s)
      "#{t.strftime('%B')} #{t.day}, #{t.year}"
    end

    # Text before <!--more--> (lists show only that part, as the theme did).
    def wp_more(html)
      parts = html.to_s.split(/<!--more(?:.*?)?-->/, 2)
      return html if parts.size == 1
      parts.first.to_s.sub(/\s*<p>\s*\z/, "\n")
    end

    # On the post's own page WordPress turns <!--more--> into an anchor.
    def wp_more_anchor(html, id)
      html.to_s.sub(/<!--more(?:.*?)?-->/, %(<span id="more-#{id}"></span>))
    end

    # Root-relative links and images -> absolute, for the RSS feed.
    def absolute_links(html)
      base = @context.registers[:site].config["url"].to_s
      html.to_s
          .gsub(/(\b(?:href|src)=["'])\/(?!\/)/) { "#{$1}#{base}/" }
          .gsub(/(\bsrcset=["'])([^"']*)/) { $1 + $2.gsub(%r{(^|,\s*)/(?!/)}) { "#{$1}#{base}/" } }
    end

    private

    def ordinal(n)
      return "#{n}th" if (11..13).cover?(n % 100)
      "#{n}#{{ 1 => 'st', 2 => 'nd', 3 => 'rd' }.fetch(n % 10, 'th')}"
    end
  end
end

Liquid::Template.register_filter(LeveesOrg::Filters)

# Per-page values the theme's <head> and <body> need, computed like WordPress.
module LeveesOrg
  def self.plain_title(t)
    t.to_s.gsub(/<[^>]+>/, "")
  end
end

Jekyll::Hooks.register :posts, :pre_render do |doc|
  d = doc.data
  t = LeveesOrg.plain_title(d["title"])
  d["body_class"] ||= "wp-singular post-template-default single single-post postid-#{d['wp_id']} single-format-standard wp-theme-levees2023"
  d["seo_title"] ||= "#{t} | #{LeveesOrg::SITE_NAME}".strip
  d["theme_title"] ||= "#{d['seo_title']}#{LeveesOrg::SITE_NAME}"
end

# (Done before rendering starts: page data is copied for Liquid before a
# per-page pre_render hook would run.)
Jekyll::Hooks.register :site, :pre_render do |site|
  by_id = site.pages.each_with_object({}) { |pg, h| h[pg.data["wp_id"]] = pg if pg.data["wp_id"] }
  site.pages.each do |page|
    next unless page.relative_path.start_with?("pages/")
    d = page.data
    # Ancestor page ids, for menu highlighting ("current-page-ancestor").
    anc = []
    pid = d["wp_parent"]
    while pid && by_id[pid] && !anc.include?(pid)
      anc << pid
      pid = by_id[pid].data["wp_parent"]
    end
    d["wp_ancestors"] = anc
    t = LeveesOrg.plain_title(d["title"])
    tpl = d["wp_template"].to_s.sub(/\.php\z/, "")
    cls = ["wp-singular"]
    cls += tpl.empty? ? ["page-template-default"] : ["page-template", "page-template-#{tpl}", "page-template-#{tpl}-php"]
    cls += ["page", "page-id-#{d['wp_id']}"]
    cls << "page-parent" if d["wp_has_children"]
    cls += ["page-child", "parent-pageid-#{d['wp_parent']}"] if d["wp_parent"]
    cls << "wp-theme-levees2023"
    d["body_class"] ||= cls.join(" ")
    d["seo_title"] ||= "#{t} | #{LeveesOrg::SITE_NAME}".strip
    d["theme_title"] ||= "#{d['seo_title']}#{LeveesOrg::SITE_NAME}"
  end
end

Jekyll::Hooks.register :documents, :pre_render do |doc|
  next unless doc.collection.label == "facts"
  d = doc.data
  t = LeveesOrg.plain_title(d["title"])
  d["body_class"] ||= "wp-singular levees_facts-template-default single single-levees_facts postid-#{d['wp_id']} wp-theme-levees2023"
  d["seo_title"] ||= "#{t} | #{LeveesOrg::SITE_NAME}".strip
  d["theme_title"] ||= "#{d['seo_title']}#{LeveesOrg::SITE_NAME}"
end
