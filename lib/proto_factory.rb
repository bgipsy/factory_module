module ProtoFactory
  def add_mapping(const, name, options = {})
    mappings[const.to_s.camelize] = Mapping.new(name.to_s.camelize, options)
  end

  def remove_mapping(const)
    mappings.delete(const.to_s.camelize)
  end

  def clear_mappings!
    mappings.clear
  end

  def const_missing(const)
    mapping = mappings[const.to_s]
    return factory_const_get(mapping.search_in || parent, mapping.name, mapping.recursive?) if mapping
    parent.const_get(const)
  end

  private

  def mappings
    @mappings ||= {}
  end

  def factory_const_get(search_in, const_name, recursive)
    const = recursive ? recursive_const_get(search_in, const_name) : non_recursive_const_get(search_in, const_name)
    raise NameError, "Factory #{name} can't find #{const_name} in #{search_in}#{recursive ? " and it's parents" : ''}" unless const
    const
  end

  def non_recursive_const_get(mod, const_name)
    mod.const_get(const_name)
  rescue NameError
    nil
  end

  def recursive_const_get(mod, const_name)
    const = non_recursive_const_get(mod, const_name)
    return const if const
    return nil if mod == Object
    recursive_const_get(mod.parent, const_name)
  end

  class Mapping
    DEFAULT_OPTIONS = {:recursive => true}.freeze

    attr_reader :name, :recursive, :search_in
    alias_method :recursive?, :recursive

    def initialize(name, options)
      options = DEFAULT_OPTIONS.merge(options)
      @name, @recursive, @search_in = name, options[:recursive] == true, options[:search_in]
    end
  end
end

module FactoryModuleExtension
  def create_factory(name = :factory)
    const_name = name.to_s.camelize
    return const_get(const_name) if const_defined?(const_name)
    const_set(const_name, Module.new {extend ProtoFactory})
  end
end

Module.send(:include, FactoryModuleExtension)
