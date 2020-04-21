require 'cgi'
require 'open-uri'

module V0
  class StaticController < ApplicationController

    skip_after_action :verify_authorized

    def home
      expires_in 5.minutes, public: true
      params[:pretty] = true
      render json: {
        notice: "Welcome. The old API has been removed.",
        api_documentation_url: "https://developer.smartcitizen.me",
        current_user_url: [request.base_url, v0_me_index_path].join,
        components_url: [request.base_url, v0_components_path].join,
        devices_url: [request.base_url, v0_devices_path].join,
        kits_url: [request.base_url, v0_kits_path].join,
        measurements_url: [request.base_url, v0_measurements_path].join,
        sensors_url: [request.base_url, v0_sensors_path].join,
        users_url: [request.base_url, v0_users_path].join,
        tags_url: [request.base_url, v0_tags_path].join,
        tags_sensors_url: [request.base_url, v0_tag_sensors_path].join,
        version_git: VERSION_FILE
      }
    end

    def metrics
      render json: {
        devices: {
          total: Device.count,
          private: Device.where(is_private: true).count,
          online: {
            now: Device.where('last_recorded_at > ?', 10.minutes.ago).count,
            last_hour: Device.where('last_recorded_at > ?', 1.hour.ago).count,
            today: Device.where('last_recorded_at > ?', Time.now.beginning_of_day).count,
            this_month: Device.where('last_recorded_at > ?', Time.now.beginning_of_month).count,
            this_year: Device.where('last_recorded_at > ?', Time.now.beginning_of_year).count,
            all_time: Device.where.not(last_recorded_at: nil).count
          },
          readings: {
            good: {
              #today: Minuteman.count("good_readings").day.count,#$analytics.day("readings:create", Time.now.utc).length,
              #this_week: Minuteman.count("good_readings").week.count#$analytics.week("readings:create", Time.now.utc).length,
            },
            bad: {
              #today: Minuteman.count("bad_readings").day.count,#$analytics.day("readings:create", Time.now.utc).length,
              #this_week: Minuteman.count("bad_readings").week.count#$analytics.week("readings:create", Time.now.utc).length,
            },
            total: nil
          }
        },
        users: {
          total: User.count,
          online: {
            now: nil
          }
        }
      }
    end

    def search
      unless params[:q]
        render json: {'Warning':'No query parameter. Use: /search?q=london'}
        return
      end

      expires_in 5.seconds, public: true
      @results = PgSearch.multisearch(params[:q]).includes(:searchable)#.map(&:searchable)
      a = []

      query = CGI.escape(params[:q]).downcase.strip

      gc = Geocoder.search(query)

      gc.take(5).each do |item|
        a << {
          type: "City", # or a Place
          city: item.city,
          name: item.display_name,
          layer: item.type,
          country_code: (ISO3166::Country.find_country_by_alpha2(item.country_code.downcase).alpha2 if item.country_code.present?),
          country: item.country,
          latitude: item.latitude,
          longitude: item.longitude
        }
      end

      a.uniq!{|h| [h[:city],h[:country_code]].join }

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
        if s.searchable.nil?
          # Record not found: multisearch table out-of-sync, delete found PgSearch::Document
          s.destroy
        else
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
      end

      paginate json: a
    end

    def version
      render json: {
        env: Rails.env,
        version: VERSION_FILE,
        ruby: RUBY_VERSION,
        rails: Rails::VERSION::STRING,
        branch: GIT_BRANCH,
        revision: GIT_REVISION,
      }
    end

  end
end
