require 'securerandom'
class Player < Hash
  include Hashie::Extensions::MethodAccess

  def entity
    Entity.new(self)
  end

  class Entity < Grape::Entity
    expose :uuid, :name
    expose :requested_name, if: lambda { |instance, options| instance.requested_name.present? }
    expose :score, if: lambda { |instance, options| instance.score.present?  }
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
      score: nil
    }
  end

end