module ProtoFactory
  def add_mapping(const, name)
    mappings[const.to_s.camelize] = name.to_s.camelize
  end

  def remove_mapping(const)
    mappings.delete(const.to_s.camelize)
  end

  def clear_mappings!
    mappings.clear
  end

  def const_missing(const)
    return recursive_const_get(parent, mappings[const.to_s]) if mappings[const.to_s]
    parent.const_get(const)
  end

  private

  def mappings
    @mappings ||= {}
  end

  def recursive_const_get(mod, const_name)
    return mod.const_get(const_name) if mod.const_defined?(const_name)
    raise NameError, "Factory #{name} can't find #{const_name}" if mod == Object
    recursive_const_get(mod.parent, const_name)
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
