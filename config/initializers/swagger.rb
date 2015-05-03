# class Swagger::Docs::Config
#   def self.transform_path(path, api_version)
#     # Make a distinction between the APIs and API documentation paths.
#     "apidocs/#{path}"
#   end
# end
Swagger::Docs::Config.base_api_controller = ActionController::API

Swagger::Docs::Config.register_apis({
  "0" => {
    # the extension used for the API
    :api_extension_type => :json,
    # the output location where your .json files are written to
    :api_file_path => "public/api",
    # the URL base path to your API
    # :base_path => "http://localhost:3000/api",
    :base_path => "https://new-api.smartcitizen.me",
    # if you want to delete all .json files at each generation
    :clean_directory => true,
    :base_api_controller => ActionController::API,
    :controller_base_path => "",
    # :controller_base_path => 'v0',
    # add custom attributes to api-docs
    :attributes => {
      :info => {
        "title" => "Swagger Sample App",
        "description" => "This is a sample description.",
        "termsOfServiceUrl" => "http://helloreverb.com/terms/",
        "contact" => "apiteam@wordnik.com",
        "license" => "Apache 2.0",
        "licenseUrl" => "http://www.apache.org/licenses/LICENSE-2.0.html"
      }
    }
  }
})
