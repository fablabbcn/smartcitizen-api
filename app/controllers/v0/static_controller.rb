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
        users_url: v0_users_url
      }
    end

    def search
      @results = PgSearch.multisearch(params[:q]).includes(:searchable)#.map(&:searchable)
      a = []
      @results.each do |s|
        h = {}
        h['id'] = s.searchable_id
        h['type'] = s.searchable_type
        if s.searchable_type == 'Device'
          h['name'] = s.searchable.name
          h['description'] = s.searchable.description
          h['owner_id'] = s.searchable.owner_id
          # h['owner_username'] = s.searchable.owner_username
          h['city'] = s.searchable.city
          h['country_code'] = s.searchable.country_code
        else
          h['username'] = s.searchable.username
          h['avatar'] = s.searchable.avatar
          h['city'] = s.searchable.city
          h['country_code'] = s.searchable.country_code
        end
        a << h
      end
      paginate json: a
    end

  end
end
