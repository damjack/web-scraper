class Entry
  extend ActiveModel::Naming
  include ActiveModel::Model
  include ActiveModel::Conversion
  attr_accessor :name, :category, :url, :cover, :abstract, :work_sections, :logo, :teams, :quote, :quote_author, :quote_role

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def complete_url
    URI.join("https://www.cantierecreativo.net", self.url).to_s
  end

  def complete_logo
    (self.logo.blank?) ? "NO LOGO" : URI.join("https://www.cantierecreativo.net", self.logo).to_s
  end

  def complete_cover
    URI.join("https://www.cantierecreativo.net", self.cover).to_s
  end
end
