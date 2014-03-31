require 'net/https'
require 'rexml/document'

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

  def copy(origin_path, dest_path)
    request(method: 'Copy', path: origin_path, dest_path: dest_path)
  end

  def move(origin_path, dest_path)
    request(method: 'Move', path: origin_path, dest_path: dest_path)
  end

  def delete(path)
    request(method: 'Delete', path: path)
  end

  def propfind(path, type)
    request(method: 'Propfind', path: path, propfind_type: type)
  end

  protected

  def xml_parse(source_xml)
    xml = REXML::Document.new(source_xml)
    if not xml.get_elements('/d:multistatus/d:response/d:propstat/d:prop/d:quota-available-bytes').empty?
      rslt = {}
      rslt[:available] = xml.get_elements('/d:multistatus/d:response/d:propstat/d:prop/d:quota-available-bytes')[0].text
      rslt[:used] = xml.get_elements('/d:multistatus/d:response/d:propstat/d:prop/d:quota-used-bytes')[0].text
    else
      rslt = []
      tmp_elm = xml.get_elements('/d:multistatus/d:response/d:href')
      tmp_elm.each { |element| rslt << element.text }
    end
    return rslt
  end

  def prep_result(result)
    resp = false
    head_ar = [Net::HTTPCreated, Net::HTTPOK]
    head_ar.each do |head|
      if result.is_a?(head)
        if result.body.empty?
          puts result.body.empty?
          resp = true
        else
          resp = result.body
        end
      elsif result.is_a?(Net::HTTPMultiStatus)
        resp = xml_parse(result.body)
      end
    end
    return resp
  end


  def request(options)

    req = eval "Net::HTTP::#{options[:method]}.new('#{options[:path]}')"
    req['Host'] = 'webdav.yandex.ru'
    req.basic_auth(@login, @password)

    if options[:method] == 'Put'
      req.content_type = 'application/octet-stream'
      req.content_length = options[:length]
      req.body_stream = options[:stream]
    elsif options[:method] == 'Copy' or options[:method] == 'Move'
      req['Destination'] = options[:dest_path]
    elsif options[:method] == 'Propfind'
      if options[:propfind_type] == :space
        req['Depth'] = 0
        xml = REXML::Document.new
        xml.add_element("D:propfind", {"xmlns:D" => "DAV:"})
        xml.root.add_element("D:prop")
        xml.root.elements[1] << REXML::Element.new("D:quota-available-bytes")
        xml.root.elements[1] << REXML::Element.new("D:quota-used-bytes")
        req.body = xml.to_s
      elsif options[:propfind_type] == :contents
        req['Depth'] = 1
      end
    end
    
    result = @http.request(req)
    prep_result(result)
  end
end 