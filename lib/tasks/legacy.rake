require 'open-uri'
require 'json'
require 'diffy'
require 'awesome_print'

class Hash
  def sorted_hash(&block)
    self.class[
      self.each do |k,v|
        self[k] = v.sorted_hash(&block) if v.class == Hash
        self[k] = v.collect {|a| a.sorted_hash(&block)} if v.class == Array
      end.sort(&block)]
  end
end

def diff path

  domains = [
  "http://api.smartcitizen.me",
  "https://new-api.smartcitizen.me"
  ]

  url = ""

  responses = []

  domains.each do |domain|
  url = [domain,path].join('/')
  responses << JSON.parse(open(url).read)
  end

  responses.map(&:sorted_hash)

  added = Diffy::Diff.new(responses[0].to_yaml, responses[1].to_yaml)

  # puts removed.to_s.red

  puts url
  puts '-' * url.length

  puts added.to_s(:color)

end

namespace :legacy do

  desc "Checks legacy API vs current API"
  task :check => :environment do

    api_key = User.where.not(legacy_api_key: nil).sample.legacy_api_key
    # diff "v0.0.1/#{api_key}/lastpost.json"
    # diff "v0.0.1/#{api_key}/me.json"
    diff "v0.0.1/#{ENV['admin_legacy_api_key']}/devices.json"

  end

end
