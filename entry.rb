require 'securerandom'
class Entry < Hash
  include Hashie::Extensions::MethodAccess

  def entity
    Entity.new(self)
  end

  class Entity < Grape::Entity
    expose :uuid, :expansion, :acro, :received_at, :accepted, :player_id
    expose :error, safe: true, if: lambda { |instance, options| !instance.error.blank? }
  end

  def initialize(hash = {})
    super
    hash.merge!(defaults)
    self['player_id']   = hash[:player_id]
    self['received_at'] = hash[:received_at]
    self['uuid']        = hash[:uuid]
    self['acro']        = hash[:acro]
    self['expansion']   = hash[:expansion]
    self['accepted']    = hash[:accepted]
    self['error']       = 'Expansion not valid for acronym' unless hash[:accepted]
  end

  private

  def defaults
    {
      uuid: SecureRandom.uuid,
      received_at: Time.now
    }
  end

end