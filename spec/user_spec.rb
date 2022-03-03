require 'json'
require_relative '../lib/user'

module ScrumTime
  RSpec.describe User do
    it 'creates a user object' do
      user_hash = { id: 1, name: 'Biggie' }

      user = User.new(user_hash)
      expect(user).to be
      expect(user).to have_attributes(user_hash)
    end
  end
end
