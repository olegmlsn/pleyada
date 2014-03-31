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
      request(method: 'Put', path: path, stream: stream, length: File.size(file))
    end
  end

  def get(path, file)
    result = request(method: 'Get', path: path)
    File.open(file, 'w') do |file|
      file << result
    end
  end

  def mkcol(path)
    request(method: 'Mkcol', path: path)
  end

  def delete(path)
    request(method: 'Delete', path: path)
  end

  protected

  def prep_result(result)
    resp = false
    head_ar = [Net::HTTPCreated, Net::HTTPOK]
    head_ar.each do |head|
      puts head
      puts result
      if result.is_a?(head)
        puts 'ok'
        if result.body.empty?
          puts result.body.empty?
          resp = true
        else
          resp = result.body
        end
      elsif result.is_a?(Net::HTTPMultiStatus)
        #TODO XML parsing
        resp = body
      end
    end
    return resp
    # if result.is_a?(Net::HTTPCreated) or result.is_a?(Net::HTTPOK) or result.is_a?(Net::HTTPMultiStatus)
    #   if result.body.empty?
    #     return true
    #   else
    #     return body
    #   end
    # elsif
    #   return false
    # end
  end

  #TODO add some magick
  def request(options)

    req = eval "Net::HTTP::#{options[:method]}.new('#{options[:path]}')"
    req['Host'] = 'webdav.yandex.ru'
    req.basic_auth(@login, @password)

    case options[:method]
    when 'Put' then
      req.content_type = 'application/octet-stream'
      req.content_length = options[:length]
      req.body_stream = options[:stream]
    end
    
    result = @http.request(req)
    prep_result(result)
  #   case options[:method]
  #   when 'PUT' then
  #     req = Net::HTTP::Put.new(options[:path])
  #     req['Host'] = 'webdav.yandex.ru'
  #     req.content_type = 'application/octet-stream'
  #     req.basic_auth(@login, @password)
  #     req.content_length = options[:length]
  #     req.body_stream = options[:stream]
  #     result = @http.request(req)
  #     if result.is_a?(Net::HTTPCreated)
  #       return true
  #     else
  #       return false
  #     end
  #   when 'GET' then
  #     req = Net::HTTP::Get.new(options[:path])
  #     req['Host'] = 'webdav.yandex.ru'
  #     req.basic_auth(@login, @password)
  #     result = @http.request(req)
  #     if result.is_a?(Net::HTTPOK)
  #       return result.body
  #     else
  #       return false
  #     end
  #   when 'MKCOL' then
  #     req = Net::HTTP::Mkcol.new(options[:path])
  #     req['Host'] = 'webdav.yandex.ru'
  #     req.basic_auth(@login, @password)
  #     result = @http.request(req)
  #     if result.is_a?(Net::HTTPCreated)
  #       return true
  #     else
  #       return false
  #     end
  #   when 'DELETE' then
  #     req = Net::HTTP::Delete.new(options[:path])
  #     req['Host'] = 'webdav.yandex.ru'
  #     req.basic_auth(@login, @password)
  #     result = @http.request(req)
  #     if result.is_a?(Net::HTTPOK)
  #       return true
  #     else
  #       return false
  #     end
  #   end
  end
end 