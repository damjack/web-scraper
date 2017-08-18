require 'open-uri'

class ScraperController < ApplicationController
  before_action :load_entries

  def index
    
  end

  def export_list
    respond_to do |format|
      format.csv do 
        csv_string = CSV.generate(headers: true) do |csv| 
          # header row
          csv << ["Name", "Category", "Link", "Cover", "Abstract", "Logo", "Quote Author", "Quote Role", "Quote Text", "Team", "Work Sections"] 
          # data rows 
          @entries.each do |entry|
            csv << [entry.name, entry.category, entry.complete_url, entry.complete_cover, entry.abstract, entry.complete_logo, entry.quote_author, entry.quote_role, entry.quote, entry.teams, entry.work_sections]
          end
        end 
        # send it to the browsah
        send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=portfolio-list-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.csv"
      end
    end
  end

  def load_entries
    @entries ||= []
    page = Nokogiri::HTML(open("https://www.cantierecreativo.net/portfolio/"))
    page.css(".isotope-layout .works-list").css(".works-list__item").map do |wli|
      @entries << Entry.new({
        name: wli.css(".works-list__item__title > div:first").text,
        category: wli.css(".works-list__item__category").text,
        url: wli.css(".works-list__item__link")[0].attributes["href"].value,
        cover: wli.css(".works-list__item__image")[0].attributes["src"].value
      })
    end

    @entries.each do |entry|
      page = Nokogiri::HTML(open(entry.complete_url))
      entry.work_sections = page.css(".work-section__title").map do |ws|
        {title: ws.text, text: ws.parent.css(".work-section__text").text} unless(ws.parent.css(".work-section__text").blank?)
      end.compact!.to_json

      both = page.css(".space--both-5")
      unless(both.blank?)
        entry.abstract = both.text
        entry.logo = both.css(".logo-portfolio")[0].attributes["src"].value
      end

      quote = page.css(".section-quote")
      unless(quote.blank?)
        entry.quote = quote.css(".quote .quote__text").text
        entry.quote_author = quote.css(".quote .quote__author").text
        entry.quote_role = quote.css(".quote .quote__role").text
      end

      teams = page.css(".work__team__holder")
      unless(teams.blank?)
        entry.teams = teams.css(".grid__item").map do |t|
          {image: t.css(".work__team__member__image")[0].attributes["src"].value, name: t.css(".work__team__member__name").text, role: t.css(".work__team__member__role").text}
        end.to_json
      end
    end
  end
end