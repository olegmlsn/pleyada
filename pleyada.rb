require 'net/https'

class Pleyada
  def initialize(login, password)
    @login = login
    @password = password
    @uri = URI('https://webdav.yandex.ru')
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = true
  end

  def put(path, file)
    File.open(file, 'r') do |stream|
      request(method: 'PUT', path: path, stream: stream, length: File.size(file))
    end
  end

  def get(path, file)
    result = request(method: 'GET', path: path)
    if result
      File.open(file, 'w') do |file|
        file << result
      end
    end
  end

  def mkcol(path)
    request(method: 'MKCOL', path: path)
  end

  def delete(path)
    request(method: 'DELETE', path: path)
  end

  protected

  #TODO add some magick
  def request(options)
    case options[:method]
    when 'PUT' then
      req = Net::HTTP::Put.new(options[:path])
      req['Host'] = 'webdav.yandex.ru'
      req.content_type = 'application/octet-stream'
      req.basic_auth(@login, @password)
      req.content_length = options[:length]
      req.body_stream = options[:stream]
      result = @http.request(req)
      if result.is_a?(Net::HTTPCreated)
        return true
      else
        return false
      end
    when 'GET' then
      req = Net::HTTP::Get.new(options[:path])
      req['Host'] = 'webdav.yandex.ru'
      req.basic_auth(@login, @password)
      result = @http.request(req)
      if result.is_a?(Net::HTTPOK)
        return result.body
      else
        return false
      end
    when 'MKCOL' then
      req = Net::HTTP::Mkcol.new(options[:path])
      req['Host'] = 'webdav.yandex.ru'
      req.basic_auth(@login, @password)
      result = @http.request(req)
      if result.is_a?(Net::HTTPCreated)
        return true
      else
        return false
      end
    when 'DELETE' then
      req = Net::HTTP::Delete.new(options[:path])
      req['Host'] = 'webdav.yandex.ru'
      req.basic_auth(@login, @password)
      result = @http.request(req)
      if result.is_a?(Net::HTTPOK)
        return true
      else
        return false
      end
    end
  end
end 