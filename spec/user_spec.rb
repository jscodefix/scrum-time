require 'json'
require_relative '../lib/user'

module ScrumTime
  RSpec.describe User do
    let(:user1) { { id: 1, name: 'Biggie' } }
    let(:user2) { { id: 2, name: 'Smalls' } }

    it 'creates a user object' do
      user = User.new(user1)

      expect(user).to be
      expect(user).to have_attributes(user1)
    end

    it 'creates an array of user objects' do
      users_array = [user1, user2]
      users = User.create_users(users_array)

      expect(users).to be_a(Array)
      expect(users.size).to eq 2
      expect(users[0]).to be_a(User)
      expect(users[1]).to be_a(User)
    end
  end
end
