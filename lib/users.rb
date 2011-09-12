require './lib/zen_api'
require 'hpricot'

class Users
  def initialize
    @resource = ZenAPI.new 'https://justinoigor.zendesk.com/', AGENT[:user], AGENT[:pwd]
  end
  
  def create xml_text
    @resource.create 'users', xml_text
  end
  
  def list
    users = []
    xml = @resource.list 'users'
    doc = Hpricot::XML xml
    (doc/'users/user').each do |el| 
      params = {}
      %w{ email id is-active name restriction-id roles }.each do |field|
        params[field] = el.at(field).inner_html
      end
      users << User.new(params)
    end
    users
  end
  
  def search_by_email email
    # Roles '0' => End Users
    xml = @resource.list_by_search_term 'users', :query => email, :roles => '0'
    doc = Hpricot::XML xml
    user = nil
    if el = (doc/'users/user').first
      params = {}
      %w{ email id is-active name restriction-id roles }.each do |field|
        params[field] = el.at(field).inner_html
      end
      user = User.new(params)
    end
    user
  end
end

class User
  attr_accessor :email, :id, :is_active, :name, :restriction_id, :roles
  
  def initialize params
    self.email = params['email']
    self.id = params['id']
    self.is_active = params['is-active']
    self.name = params['name']
    self.restriction_id = params['restriction-id']
    self.roles = params['roles']
  end
  
  def self.create! params
    user = User.new params
    # Restriction ID '4' => Tickets requested by user
    user.restriction_id = '4'
    # Role '0' => End User
    user.roles = '0'
    if user.validate
      Users.new.create user.to_xml
    else
      false
    end
  end
  
  def to_s
    to_xml
  end
  
  def to_xml
    "<user>
      <email>#{self.email}</email>
      <name>#{self.name}</name>
      <restriction-id>#{self.restriction_id}</restriction-id>
      <roles>#{self.roles}</roles>
    </user>"
  end
  
  def validate
    !self.email.nil? && !self.email.empty? && !self.name.nil? && !self.name.empty?
  end
end