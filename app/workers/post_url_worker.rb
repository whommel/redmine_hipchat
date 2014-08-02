class PostUrlWorker
  include Sidekiq::Worker

  def perform(request_uri, host, port, form_data, content_type, use_ssl)
    req = Net::HTTP::Post.new(request_uri)
    req.set_form_data(form_data)
    req["Content-Type"] = content_type

    http = Net::HTTP.new(host, port)
    http.use_ssl = use_ssl
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    begin
      http.start do |connection|
        connection.request(req)
      end
    rescue Net::HTTPBadResponse => e
      Rails.logger.error "Error hitting HipChat API: #{e}"
    end
  end
end
