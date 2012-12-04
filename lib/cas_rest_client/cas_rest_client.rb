class CasRestClient

  @cas_opts = nil
  @tgt = nil
  @cookies = nil
  DEFAULT_OPTIONS = {:use_cookies => true}

  def initialize(cas_opts = {})
    @cas_opts = DEFAULT_OPTIONS.merge(get_cas_config).merge(cas_opts)

    begin
      get_tgt
    rescue RestClient::BadRequest => e
      raise RestClient::Request::Unauthorized.new
    end
  end

  def get(uri, options = {})
    execute("get", uri, {}, options)
  end

  def delete(uri, options = {})
    execute("delete", uri, {}, options)
  end

  def post(uri, params = {}, options = {})
    execute("post", uri, params, options)
  end

  def put(uri, params = {}, options = {})
    execute("put", uri, params, options)
  end

  private
  def execute(method, uri, params, options)
    if @cas_opts[:use_cookies]
      begin
        execute_with_cookie(method, uri, params, options)
      rescue RestClient::Request::Unauthorized => e
        execute_with_tgt(method, uri, params, options)
      end
    else
      execute_with_tgt(method, uri, params, options)
    end
  end

  def execute_with_cookie(method, uri, params, options)
    return RestClient.send(method, uri, {:cookies => @cookies}.merge(options)) if params.empty?
    RestClient.send(method, uri, params, {:cookies => @cookies}.merge(options))
  end

  def execute_with_tgt(method, uri, params, options)
    get_tgt unless @tgt

    ticket = nil
    begin
      ticket = create_ticket(@tgt, :service => @cas_opts[:service] || uri)
    rescue RestClient::ResourceNotFound => e
      get_tgt
      ticket = create_ticket(@tgt, :service => @cas_opts[:service] || uri)
    end
    response = RestClient.send(method, "#{uri}#{uri.include?("?") ? "&" : "?"}ticket=#{ticket}", options) if params.empty?
    response = RestClient.send(method, "#{uri}#{uri.include?("?") ? "&" : "?"}ticket=#{ticket}", params, options) unless params.empty?
    @cookies = response.cookies
    response
  end

  def create_ticket(uri, params)
    ticket = RestClient.post(uri, params)
    ticket = ticket.body if ticket.respond_to? 'body'
    ticket
  end

  def get_tgt
    opts = @cas_opts.dup
    opts.delete(:service)
    opts.delete(:use_cookies)
    @tgt = RestClient.post(opts.delete(:uri), opts).headers[:location]
  end

  def get_cas_config
    begin
      cas_config = YAML.load_file("config/cas_rest_client.yml")
      cas_config = cas_config[Rails.env] if defined?(Rails) and Rails.env

      cas_config = cas_config.inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    rescue Exception
      cas_config = {}
    end
    cas_config
  end
end


