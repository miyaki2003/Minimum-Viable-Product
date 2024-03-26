require 'chronic'
require 'active_support/time'

module TimeParser
  def self.parse_natural_language_to_time(natural_language_time)
    Chronic.time_class = Time.zone
    Chronic.parse(natural_language_time)
  end
end