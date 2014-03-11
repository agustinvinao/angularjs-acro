require 'securerandom'
class Vote < Hash
  include Hashie::Extensions::MethodAccess

  def entity
    Entity.new(self)
  end

  class Entity < Grape::Entity
    expose :uuid, :entry, :received_at, :accepted
    expose :error, safe: true, if: lambda { |instance, options| !instance.error.blank? }
  end

  def initialize(hash = {})
    super
    hash.merge!(defaults)
    self['received_at'] = hash[:received_at]
    self['uuid']        = hash[:uuid]
    self['player_id']   = hash[:player_id]
    self['entry']       = hash[:entry]
    self['accepted']    = hash[:accepted]
    self['error']       = 'Vote received too late' unless hash[:accepted]
  end

  private

  def defaults
    {
      uuid: SecureRandom.uuid,
      received_at: Time.now
    }
  end

end