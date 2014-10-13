require 'data_mapper'
require 'dm-postgres-adapter'

DataMapper.setup(:default, ENV['DATABASE_URL'])

class User
  include DataMapper::Resource

  # Authentication & Identification
  property :id, String, key: true
  property :token, String
  property :secret, String
  property :screen_name, String

  # Date & Time
  property :created_at, DateTime
  property :updated_at, DateTime

  class << self

    # Find or create, and update a `User` by `OAuth::AccessToken`, then return the User's ID
    #
    # @param [OAuth::AccessToken]
    # @return [String] User ID
    def login(access_token)
      id = access_token.params['user_id']
      first_or_create(id: id).update(
        token: access_token.token,
        secret: access_token.secret,
        screen_name: access_token.params['screen_name'])
      id
    end

  end

end

DataMapper.finalize
