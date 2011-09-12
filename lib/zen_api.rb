require 'rest_client'

class ZenAPI
  attr_accessor :user, :pass, :url
  
  def initialize url, user, pass
    self.url = url
    self.user = user
    self.pass = pass
  end
  
  def create resource, xml_text
    private_resource = RestClient::Resource.new "#{self.url}#{resource}.xml", self.user, self.pass
    private_resource.post xml_text, :content_type => :xml
  end
  
  def delete resource, id
    private_resource = RestClient::Resource.new "#{self.url}#{resource}/#{id}.xml", self.user, self.pass
    private_resource.delete
  end
  
  def list resource
    private_resource = RestClient::Resource.new "#{self.url}#{resource}.xml", self.user, self.pass
    private_resource.get
  end
  
  def list_by_search_term resource, params = {}
    private_resource = RestClient::Resource.new "#{self.url}#{resource}.xml", self.user, self.pass
    private_resource.get({ :params => params })
  end
  
  def show resource, id
    private_resource = RestClient::Resource.new "#{self.url}#{resource}/#{id}.xml", self.user, self.pass
    private_resource.get
  end
  
  def update resource, id, xml_text
    private_resource = RestClient::Resource.new "#{self.url}#{resource}/#{id}.xml", self.user, self.pass
    private_resource.put xml_text, :content_type => :xml
  end
end