require 'cgi'
require 'open-uri'

module V0
  class StaticController < ApplicationController

    skip_after_action :verify_authorized

    def home
      expires_in 5.minutes, public: true
      params[:pretty] = true
      render json: {
        notice: "!!! This is the new API. The old API is here - http://api.smartcitizen.me/v0.0.1 !!!",
        api_documentation_url: "https://developer.smartcitizen.me",
        current_user_url: ['https://api.smartcitizen.me', v0_me_index_path].join,
        components_url: ['https://api.smartcitizen.me', v0_components_path].join,
        devices_url: ['https://api.smartcitizen.me', v0_devices_path].join,
        kits_url: ['https://api.smartcitizen.me', v0_kits_path].join,
        measurements_url: ['https://api.smartcitizen.me', v0_measurements_path].join,
        sensors_url: ['https://api.smartcitizen.me', v0_sensors_path].join,
        users_url: ['https://api.smartcitizen.me', v0_users_path].join,
        tags_url: ['https://api.smartcitizen.me', v0_tags_path].join
      }
    end

    def metrics
      render json: {
        devices: {
          total: Device.count,
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
              today: Minuteman.count("good_readings").day.count,#$analytics.day("readings:create", Time.now.utc).length,
              this_week: Minuteman.count("good_readings").week.count#$analytics.week("readings:create", Time.now.utc).length,
            },
            bad: {
              today: Minuteman.count("bad_readings").day.count,#$analytics.day("readings:create", Time.now.utc).length,
              this_week: Minuteman.count("bad_readings").week.count#$analytics.week("readings:create", Time.now.utc).length,
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
      expires_in 5.seconds, public: true
      @results = PgSearch.multisearch(params[:q]).includes(:searchable)#.map(&:searchable)
      a = []

      query = CGI.escape(params[:q]).downcase.strip

      begin
        url = "http://search.mapzen.com/v1/autocomplete?api_key=#{ENV['mapzen_api_key']}&text=#{query}"
        if Rails.env.test?
          data = JSON.parse( open(url).read ) # let VCR handle it
        else
          data = JSON.parse( APICache.get(url, cache: 5.days, valid: 1.week) )
        end
        data['features'].take(5).each do |feature|
          a << {
            type: "City",
            city: feature['properties']['name'],
            name: feature['properties']['name'],
            layer: feature['properties']['layer'],
            country_code: (ISO3166::Country.find_country_by_alpha3(feature['properties']['country_a'].downcase).alpha2 if feature['properties']['country_a']),
            country: feature['properties']['country'],
            latitude: feature['geometry']['coordinates'][1],
            longitude: feature['geometry']['coordinates'][0]
          }
        end
      rescue Exception => e
        #notify_airbrake(e)
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

  end
end
