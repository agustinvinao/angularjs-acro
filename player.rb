require 'securerandom'
class Player < Hash
  include Hashie::Extensions::MethodAccess

  def entity
    Entity.new(self)
  end

  class Entity < Grape::Entity
    expose :uuid, :name
    expose :requested_name, unless: lambda { |instance, options| instance.requested_name.nil? }
    expose :score, unless: lambda { |instance, options| instance.score.nil? }
  end

  def initialize(hash = {})
    super
    hash.merge!(defaults)
    self['uuid']           = hash[:uuid]
    self['name']           = hash[:name]
    self['requested_name'] = hash[:requested_name]
    self['score']          = hash[:score]
  end

  private

  def defaults
    {
      uuid: SecureRandom.uuid,
      score: 0
    }
  end

end