class UserCache < ActiveRecord::Base
  def self.create_if_not_exists(options)
    find_by_nsid(options[:nsid]) or create(options)
  end
end
