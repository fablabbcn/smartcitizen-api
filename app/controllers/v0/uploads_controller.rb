module V0
class UploadsController < ApplicationController

    before_action :check_if_authorized!, only: [:create]
    after_action :verify_authorized, only: [:create]

    # create the document in rails, then send json back to our javascript to populate the form that will be
    # going to amazon.
    def create
      check_missing_params 'filename'
      @avatar = current_user.uploads.create(original_filename: params[:filename])
      authorize current_user, :update?
      response.headers.except! 'X-Frame-Options'
      render :json => {
        :policy => s3_upload_policy_document,
        :signature => s3_upload_signature,
        :key => @avatar.key
        # :success_action_redirect => devices_url
      }
    end

    def uploaded
      check_missing_params 'key'
      upload = Upload.find_by(key: CGI.unescape(params[:key]) )
      upload.user.update_attribute(:avatar_url, upload.full_path)
      # head :ok
      render json: {message: 'OK'}, status: :ok
    end

    # # just in case you need to do anything after the document gets uploaded to amazon.
    # # but since we are sending our docs via a hidden iframe, we don't need to show the user a
    # # thank-you page.
    # def s3_confirm
    #   head :ok
    # end

private

    # generate the policy document that amazon is expecting.
    def s3_upload_policy_document
      return @policy if @policy
      ret = {"expiration" => 5.minutes.from_now.utc.xmlschema,
        "conditions" =>  [
          {"bucket" =>  ENV['s3_bucket']},
          ["starts-with", "$key", @avatar.key],
          {"acl" => "public-read"},
          {"success_action_status" => "200"},
          ["content-length-range", 0, 1073741824] # 100 MB
        ]
      }
      @policy = Base64.encode64(ret.to_json).gsub(/\n/,'')
    end

    # sign our request by Base64 encoding the policy document.
    def s3_upload_signature
      signature = Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest::Digest.new('sha1'),
          (ENV['aws_secret_key'] || 'key_not_found'),
          s3_upload_policy_document
        )
      ).gsub("\n","")
    end

  end
end
