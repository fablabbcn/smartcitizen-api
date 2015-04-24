class DetailedKitSerializer < KitSerializer

  def attributes
    hash = super
    if object.sensors
      hash = hash.merge(sensors: object.sensors)
      # if Pundit.policy(current_user, object).update?
      #   hash = hash.merge(mac_address: object.mac_address)
      # end
    end
    hash
  end

end
