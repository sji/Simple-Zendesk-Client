require './lib/zen_api'
require 'hpricot'

class Tickets
  def initialize
    @resource = ZenAPI.new 'https://justinoigor.zendesk.com/', AGENT[:user], AGENT[:pwd]
  end
  
  def create xml_text
    @resource.create 'tickets', xml_text
  end
  
  def find_by_id id
    ticket = nil
    xml = @resource.show 'tickets', id
    doc = Hpricot::XML xml
    (doc/'ticket').each do |el| 
      params = {}
      %w{ current-tags description nice-id priority-id requester-id status-id subject ticket-type-id }.each do |field|
        params[field] = el.at(field).inner_html
      end
      ticket = Ticket.new(params)
    end
    ticket
  end
  
  def list
    tickets = []
    xml = @resource.list('tickets')
    doc = Hpricot::XML xml
    (doc/'tickets/ticket').each do |el| 
      params = {}
      %w{ current-tags description nice-id priority-id requester-id status-id subject ticket-type-id }.each do |field|
        params[field] = el.at(field).inner_html
      end
      tickets << Ticket.new(params)
    end
    tickets
  end
  
  def list_by_requester_id id
    list.reject { |ticket| ticket.requester_id != id  }
  end

  def update id, xml_text
    @resource.update 'tickets', id, xml_text
  end
end

class Ticket
  attr_accessor :current_tags, :description, :nice_id, :priority_id, :requester_id, :status_id, :subject, :ticket_type_id
  alias_method :id, :nice_id
  
  def initialize params
    self.current_tags = params['current-tags']
    self.description = params['description']
    self.nice_id = params['nice-id']
    self.priority_id = params['priority-id']
    self.requester_id = params['requester-id']
    self.status_id = params['status-id']
    self.subject = params['subject']
    self.ticket_type_id = params['ticket-type-id']
  end
  
  def self.create! params
    ticket = Ticket.new params
    if ticket.validate
      Tickets.new.create ticket.to_xml
    else
      false
    end
  end
  
  def get_status
    unless self.status_id.nil?
      { '0' => 'New', '1' => 'Open', '2' => 'Pending', '3' => 'Solved', '4' => 'Closed' }.fetch self.status_id, '-'
    else
      '-'
    end
  end
  
  def to_s
    to_xml
  end
  
  def to_xml
    "<ticket>
      <current-tags>#{self.current_tags}</current-tags>
      <description>#{self.description}</description>
      <priority-id>#{self.priority_id}</priority-id>
      <requester-id>#{self.requester_id}</requester-id>
      <status-id >#{self.status_id}</status-id>
      <subject>#{self.subject}</subject>
      <ticket-type-id>#{self.ticket_type_id}</ticket-type-id>
    </ticket>"
  end
  
  def mark_as_solved!
    # Status Id '3' - Solved
    self.status_id = '3'
    Tickets.new.update self.nice_id, to_xml
  end
  
  def validate
    !self.description.nil? && !self.description.empty? && !self.requester_id.nil? && !self.requester_id.empty?
  end
end