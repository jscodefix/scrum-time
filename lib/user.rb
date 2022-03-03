# frozen_string_literal: true

module ScrumTime
  class User
    attr_reader :id, :name

    def initialize(user_hash)
      @id = user_hash[:id]
      @name = user_hash[:name]
    end

    def self.create_users(user_array)
      user_array.map do |user|
        User.new(user)
      end
    end
  end
end
