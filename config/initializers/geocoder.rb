# if Rails.env.test?
#   Geocoder.configure(:lookup => :test)

#   Geocoder::Lookup::Test.add_stub(
#     "Craig Wen", [
#       {
#         'latitude'     => 53.3069303,
#         'longitude'    => -3.7495789,
#         'address'      => 'Craig Wen',
#         'state'        => 'Rhos on Sea',
#         'country'      => 'United Kingdom',
#         'country_code' => 'GB'
#       }
#     ]
#   )
# end

if false#Rails.env.production?
  Geocoder.configure(
    # geocoding options
      :timeout      => 3,           # geocoding service timeout (secs)
      :lookup       => :google,     # name of geocoding service (symbol)
      :language     => :en,         # ISO-639 language code
      :use_https    => false,       # use HTTPS for lookup requests? (if supported)
      :http_proxy   => nil,         # HTTP proxy server (user:pass@host:port)
      :https_proxy  => nil,         # HTTPS proxy server (user:pass@host:port)
      :api_key      => nil,         # API key for geocoding service
      :cache        => Redis.new,         # cache object (must respond to #[], #[]=, and #keys)
      :cache_prefix => "geocoder:", # prefix (string) to use for all cache keys

      # exceptions that should not be rescued by default
      # (if you want to implement custom error handling);
      # supports SocketError and TimeoutError
      # :always_raise => [],

      # calculation options
      :units     => :km,       # :km for kilometers or :mi for miles
      :distances => :spherical    # :spherical or :linear
  )
end
