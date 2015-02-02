class Sensor < ActiveRecord::Base

  has_many :components
  has_many :boards, through: :components
  has_many :kits, through: :components

  has_ancestry
  validates_presence_of :name, :description#, :unit

end


# tags -

# light
# temperature
# humidity
# no2
# co
# battery
# power
# noise
# lat,lng
