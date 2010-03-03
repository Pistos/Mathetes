require 'hpricot'
require 'json'
require 'open-uri'

class Feed
  def self.parse( uri )
    doc = Hpricot.XML(open(uri))
    feed = new(uri)

    if doc.at(:item)
      feed.parse_rss2(doc)
    elsif doc.at(:entry)
      feed.parse_atom(doc)
    else
      raise ArgumentError, "Cannot parse this"
    end

    feed
  end

  attr_reader :meta, :children

  def initialize(uri)
    @children = []
    @meta = Meta.new(self)
  end

  def parse_atom(doc)
    parse_meta(doc, :feed)
    parse_common(doc, :entry, Entry)
  end

  def parse_rss2(doc)
    parse_meta(doc, 'rss/channel')
    parse_common(doc, :item, Item)
  end

  def parse_common(doc, selector, klass)
    (doc/selector).each do |node|
      @children << obj = klass.new(self)
      node.children.each do |child|
        next unless child.respond_to?(:name)
        obj[child.name] = child
      end
    end
  end

  def parse_meta(doc, selector)
    (doc/selector).each do |node|
      node.children.each do |child|
        next unless child.respond_to?(:name)
        next if child.name == 'entry' || child.name == 'item'
        @meta[child.name] = child
      end
    end
  end

  class Child
    HANDLE_TIME   = lambda{|time| Time.parse(time.inner_text.strip) }
    HANDLE_LINK   = lambda{|link| link[:href] }
    HANDLE_AUTHOR = lambda{|author|
      hold = {}
      author.children.each do |child|
        next unless child.respond_to?(:name)
        hold[child.name] = child.inner_text.strip
      end
      hold
    }

    attr_reader :parent, :list

    def initialize(parent)
      @parent = parent
      @list = {}
    end

    def []=(key, value)
      handler = self.class::HANDLE[key]
      @list[key.to_s] = handler ? handler.call(value) : value.inner_text.strip
    end

    def [](key)
      @list[key.to_s]
    end
  end

  class Item < Child
    HANDLE = { 'pubDate' => HANDLE_TIME }
    def author
      self[ 'author' ]
    end
    def title
      self[ 'title' ]
    end
    def link
      self[ 'link' ]
    end
    def guid
      self[ 'guid' ]
    end
  end

  class Entry < Child
    HANDLE = { 'link' => HANDLE_LINK, 'author' => HANDLE_AUTHOR,
      'updated' => HANDLE_TIME, 'published' => HANDLE_TIME }
  end

  class Meta < Child
    HANDLE = { 'link' => HANDLE_LINK, 'author' => HANDLE_AUTHOR,
      'updated' => HANDLE_TIME }
  end
end