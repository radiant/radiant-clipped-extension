module TagDeprecation
  
  # I have been experimenting with various parser-level mechanisms for tag substitution
  # but they are all quite fragile when you get to context-sensitivity.
  # assets:url has gone, for example, but not assets:first, so the deprecation of `assets` is not simple.
  # It's less dry but much easier to address at this level, where we can deal with definitions instead of tokens.

  # Deprecations are remembered so that a (future) rake task can scan through page parts, layouts and snippets to
  # report and repair.
  def self.included(base)
    base.send :mattr_accessor, :tag_deprecations
    base.extend ClassMethods
  end
  
  module ClassMethods

    # Define a tag while also deprecating it. Normal usage:
    #
    #   deprecated_tag 'old:way', :substitute => 'new:way', :deadline => '1.1.1'
    #
    # If no substitute is given then a warning will be issued but nothing rendered. 
    # If a deadline version is provided then it will be mentioned in the deprecation warnings.
    #
    # In more complex situations you can use deprecated_tag in exactly the 
    # same way as tags are normally defined:
    #
    # desc %{
    #   Please note that the old r:busted namespace is no longer supported. 
    #   Refer to the documentation for more about the new r:hotness tags.
    # }
    # deprecated_tag 'busted' do |tag|
    #   raise TagError "..."
    # end
    #
    def deprecated_tag(name, options={}, &block)
      @@tag_deprecations ||= {}
      @@tag_deprecations[name.to_sym] = options
      
      self.tag_descriptions[name] = Radiant::Taggable.last_description if Radiant::Taggable.last_description
      Radiant::Taggable.last_description = nil
      
      if block
        # notify_of_deprecation(name, options)
        define_method("tag:#{name}", &block)
      else
        define_method("tag:#{name}") do |tag|
          # result = notify_of_deprecation(name, options)
          
          message = "Deprecated radius tag #{name}"
          message << " will be removed in radiant #{options[:deadline]}" if options[:deadline]
          Rails.logger.warn(message)
          
          tag.render(options[:substitute], tag.attr.dup, &tag.block) if options[:substitute]
        end
      end
    end

    # Ideally I would like this to notify people of where the bad tag was found,
    # ie in what snippet, layout or page, but it's not easy to establish what is the salient context

    def notify_of_deprecation(name, options={})
      message = "Deprecated radius tag #{name}"
      message << " will be removed in radiant #{options[:deadline]}" if options[:deadline]
      Rails.logger.warn(message)
      if RAILS_ENV == 'development' && Radiant::Config['assets.show_deprecation']
        %{<span class="deprecation">#{name} tag is deprecated.</span>}
      else
        ""
      end
    end
  end 
  
end