class Premailer
  module Rails
    module CSSLoaders
      module AssetPipelineLoader
        extend self
        def asset_pipeline_present?
          false
        end
      end
    end
  end
end