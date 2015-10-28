if Rails.env.test?
  Geocoder.configure(:lookup => :test)

  # IAAC, Barcelona, Spain
  Geocoder::Lookup::Test.add_stub(
    [41.3966908, 2.1921909], [
      {
        'latitude'     => 41.3966908,
        'longitude'    => 2.1921909,
        "city"=>"Barcelona",
        "state"=>"Catalunya",
        "address"=>"Carrer de Pallars, 122, 08018 Barcelona, Barcelona, Spain",
        "country"=>"Spain",
        "state_code"=>"CT",
        "postal_code"=>"08018",
        "country_code"=>"ES"
      }
    ]
  )

  # Spreepark, Berlin, Germany
  Geocoder::Lookup::Test.add_stub(
    [52.4850463,13.489651], [
      {
        'latitude'     => 52.4850463,
        'longitude'    => 13.489651,
        "city"=>"Berlin",
        "state"=>"Berlin",
        "address"=>"Wasserweg, 12437 Berlin, Germany",
        "country"=>"Germany",
        "state_code"=>"Berlin",
        "postal_code"=>"12437",
        "country_code"=>"DE"
      }
    ]
  )

  # Eiffel Tower, Paris, France
  Geocoder::Lookup::Test.add_stub(
    [48.8582606,2.2923184], [
      {
        'latitude'     => 48.8582606,
        'longitude'    => 2.2923184,
        "city"=>"Paris",
        "state"=>"Île-de-France",
        "address"=>"69 Quai Branly, 75007 Paris, France",
        "country"=>"France",
        "state_code"=>"IDF",
        "postal_code"=>"75007",
        "country_code"=>"FR"
      }
    ]
  )

  # Old Trafford Stadium, Manchester, UK
  Geocoder::Lookup::Test.add_stub(
    [53.4630589,-2.2935288], [
      {
        'latitude'     => 53.4630589,
        'longitude'    => -2.2935288,
        "city"=>"Stretford",
        "state"=>nil,
        "address"=>"United Rd, Stretford, Manchester M16, UK",
        "country"=>"United Kingdom",
        "state_code"=>nil,
        "postal_code"=>"M16",
        "country_code"=>"GB"
      }
    ]
  )

  # London Eye - London, UK
  Geocoder::Lookup::Test.add_stub(
    [51.503324,-0.1217317], [
      {
        'latitude'     => 51.503324,
        'longitude'    => -0.1217317,
        "city"=>"South Bank",
        "state"=>nil,
        "address"=>"London Eye Pier, Westminster Bridge Road, Lambeth, London Se1 7PB, UK",
        "country"=>"United Kingdom",
        "state_code"=>nil,
        "postal_code"=>"Se1 7PB",
        "country_code"=>"GB"
      }
    ]
  )

  # Two Oceans Aquarium, Cape Town, South Africa
  Geocoder::Lookup::Test.add_stub(
    [-33.9080317,18.4154827], [
      {
        'latitude'     => -33.9080317,
        'longitude'    => 18.4154827,
        "city"=>"Cape Town",
        "state"=>"Western Cape",
        "address"=>"0C Dock Rd, V & A Waterfront, Cape Town, 8001, South Africa",
        "country"=>"South Africa",
        "state_code"=>"WC",
        "postal_code"=>"8001",
        "country_code"=>"ZA"
      }
    ]
  )

end

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
