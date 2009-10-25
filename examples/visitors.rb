# Let's suppose that some user_tracking_plugin wants to give
# its users ability to subclass SiteVistor and instantiate that
# user classes instead of it's own

# in user_tracking_plugin/app/models/user_tracking/site_visitor.rb
module UserTracking
  class SiteVisitor
    def self.api_find_or_create_by_request(http_request)
      api_response = ...
      new(api_response)
    end

    def initialize(api_response)
      ...
    end

    def featured_links
      ...
    end
  end
end

# in user_tracking_plugin/app/models/user_tracking/factory.rb
module UserTracking
  create_factory
end

# in user_tracking_plugin/app/constrollers/user_tracking/controller_base.rb
module UserTracking
  class ControllerBase
    before_filter :track_visitor

    protected

    def track_visitor
      @visitor = UserTracking::Factory::SiteVisitor.api_find_or_create_by_request(request)
    end
  end
end

#
# ... and in some application that includes this plugin ...
#

# in config/environment.rb

config.after_initialize do
  UserTracking::Factory.add_mapping :site_visitor, :fancy_visitor
end

# in app/models/fancy_visitor.rb

class FancyVisitor < UserTracking::SiteVisitor
  def initialize(request)
    super
    @fancy_links = another_api_get_very_special_links(self.api_id)
  end

  def featured_links
    @fancy_links + super # I love super
  end
end
