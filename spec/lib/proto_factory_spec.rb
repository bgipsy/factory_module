require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProtoFactory do
  module ModuleA
    class X; end
    class OtherX; end
  end

  module B
    module C
      class Y; end
    end
    class OtherY; end
  end
  class YetAnotherY; end

  it "should create factory module in global namespace" do
    lambda { ::Factory }.should raise_error
    Object.const_defined?('Factory').should == false
    Object.create_factory
    Object.const_defined?('Factory').should == true
    lambda { ::Factory }.should_not raise_error
  end

  it "should create factory for specific module" do
    lambda { ModuleA::Factory }.should raise_error
    ModuleA.const_defined?('Factory').should == false
    ModuleA.create_factory
    ModuleA.const_defined?('Factory').should == true
    lambda { ModuleA::Factory }.should_not raise_error
  end

  it "should not create factories twice" do
    instance1 = ModuleA.create_factory
    ModuleA::Factory.add_mapping(:foo, :bar)
    instance2 = ModuleA.create_factory
    instance1.should == instance2
    instance2.send(:mappings).keys.should include('Foo')
  end

  it "should allow to have several factories" do
    instance1 = ModuleA.create_factory
    ModuleA::Factory.add_mapping(:foo, :bar)
    instance2 = ModuleA.create_factory(:another_factory)
    instance1.should_not == instance2
    instance2.send(:mappings).should_not include('Foo')
  end

  it "should return original class if it has no mappings" do
    ModuleA.create_factory
    ModuleA::Factory::X.should == ModuleA::X
  end

  it "should remove mapping" do
    ModuleA.create_factory
    ModuleA::Factory.add_mapping(:x, :other_x)
    ModuleA::Factory.remove_mapping(:x)
    ModuleA::Factory::X.should == ModuleA::X
  end

  it "should remove all mappings" do
    ModuleA.create_factory
    ModuleA::Factory.add_mapping(:x, :other_x)
    ModuleA::Factory.clear_mappings!
    ModuleA::Factory::X.should == ModuleA::X
  end

  it "should return specific class if it has a mapping for it" do
    ModuleA.create_factory
    ModuleA::Factory.add_mapping(:x, :other_x)
    ModuleA::Factory::X.should == ModuleA::Factory::OtherX
  end

  it "should look for class in parent modules" do
    B::C.create_factory
    B::C::Factory::Y.should == B::C::Y

    B::C::Factory.add_mapping(:y, :other_y)
    B::C::Factory::Y.should == B::OtherY

    B::C::Factory.add_mapping(:y, :yet_another_y)
    B::C::Factory::Y.should == YetAnotherY
  end

  it "should raise error when mapping can't be resoved" do
    B::C.create_factory
    B::C::Factory.add_mapping(:y, :non_existent_y)
    lambda { B::C::Factory::Y }.should raise_error(NameError)
  end
end
