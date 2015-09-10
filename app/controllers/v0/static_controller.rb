module V0
  class StaticController < ApplicationController

    skip_after_action :verify_authorized

    def home
      params[:pretty] = true
      render json: {
        current_user_url: v0_me_index_url,
        components_url: v0_components_url,
        devices_url: v0_devices_url,
        kits_url: v0_kits_url,
        measurements_url: v0_measurements_url,
        sensors_url: v0_sensors_url,
        users_url: v0_users_url,
        tags_url: v0_tags_url,
      }
    end

    def search
      @results = PgSearch.multisearch(params[:q]).includes(:searchable)#.map(&:searchable)
      a = []


      Place.select("DISTINCT on (country_code) country_code, country_name, lat, lng").where("country_name ILIKE :q", q: "%#{params[:q]}%").limit(3).each do |p|
        a << {
          type: "Country",
          country_code: p.country_code,
          country: p.country_name,
          latitude: p.lat,
          longitude: p.lng
        }
      end

      Place.where("name ILIKE :q", q: "%#{params[:q]}%").limit(5).each do |p|
        a << {
          type: "City",
          city: p.name,
          country_code: p.country_code,
          country: p.country_name,
          latitude: p.lat,
          longitude: p.lng
        }
      end

      Tag.where("name ILIKE :q", q: "%#{params[:q]}%").limit(5).each do |t|
        a << {
          id: t.id,
          type: "Tag",
          name: t.name,
          description: t.description,
          url: v0_devices_url(with_tags: t.name)
        }
      end

      @results.each do |s|
        h = {}
        h['id'] = s.searchable_id
        h['type'] = s.searchable_type
        if s.searchable_type == 'Device'
          h['name'] = s.searchable.name
          h['description'] = s.searchable.description
          h['owner_id'] = s.searchable.owner_id
          h['owner_username'] = s.searchable.owner_username
          h['city'] = s.searchable.city
          h['url'] = v0_device_url(s.searchable_id)
        elsif s.searchable_type == 'User'
          h['username'] = s.searchable.username
          h['avatar'] = s.searchable.avatar
          h['city'] = s.searchable.city
          h['url'] = v0_user_url(s.searchable_id)
        end
          h['country_code'] = s.searchable.country_code
          h['country'] = s.searchable.country_name
        a << h
      end

      paginate json: a
    end

  end
end
