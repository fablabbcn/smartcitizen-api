module CountryMethods
  extend ActiveSupport::Concern

  included do

    def country_code
      super.try(:upcase)
    end

  end

  def country
    if country_code and country_code.match /\A\w{2}\z/
      ISO3166::Country[country_code]
    end
  end

  def country_name
    country ? country.to_s : nil
  end

end
