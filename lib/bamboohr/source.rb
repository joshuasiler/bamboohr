module BambooHR

  class Source
    attr_reader :resource
    
    def initialize(subdomain = nil, secret = nil)
      subdomain ||= ENV['BAMBOOHR_SUBDOMAIN']
      secret ||= ENV['BAMBOOHR_SECRET']
      password = "%04d" % rand(9999)
      
      raise "BambooHR Subdomain must be defined via the API or the env variable BAMBOOHR_SUBDOMAIN" if subdomain.nil?
      raise "BambooHR API Secret must be defined via the API or the env variable BAMBOOHR_SECRET" if secret.nil?
      
      @resource = RestClient::Resource.new 'https://api.bamboohr.com/api/gateway.php/' + subdomain, secret, password
    end    
    
    # Fields
    def fields
      @fields ||= get_xml('v1/meta/fields').xpath('//field').map do |field|
        Field.new(field['id'].to_i, field['type'].to_sym, field['alias'], field.content)
      end
    end
    
    def report
      Report.new(self)
    end
    
    protected
    
    # Returns parsed XML
    def get_xml(path)
      Nokogiri::XML(resource[path].get)
    end
    
  end

end