require 'mediawiki_api'
namespace :db do
    task :amend_date => :environment do
        commons = MediawikiApi::Client.new("https://commons.wikimedia.org/w/api.php")
        commons.log_in(ENV["USERNAME"], ENV["PASSWORD"])
        Photo.where(date: Date.parse("1 jan 2000")..Date.parse("31 dec 2020")).each do |p|
            next if p.descriptionurl.nil?
            puts "#{p.title} - Doing #{p.descriptionurl.split("/")[4]}"
            wikitext = commons.query prop: :revisions, titles: CGI.unescape(p.descriptionurl.split("/")[4]), rvprop: :content, rvslots: "*"
            next if wikitext.data["pages"].first.try(:[], 1).try(:[], "revisions").try(:[], 0).try(:[],"slots").try(:[], "main").try(:[],"*").nil?
            text = String.new(wikitext.data["pages"].first.try(:[], 1).try(:[], "revisions").try(:[], 0).try(:[],"slots").try(:[], "main").try(:[],"*"))
            text.gsub!(/{{Monumento italiano\|([\w\d]+)\|anno=20[012][023456789]}}/i, '{{Monumento italiano|\1|anno=2021}}')
            text.gsub!(/{{Wiki Loves Monuments 20[012][023456789]\|it}}/i, "{{Wiki Loves Monuments 2021|it}}")
            text.gsub!(/{{Load via app WLM\.it\|year=20[012][023456789]}}/i, "{{Load via app WLM.it|year=2021}}")
            unless text == wikitext.data["pages"].first.try(:[], 1).try(:[], "revisions").try(:[], 0).try(:[],"slots").try(:[], "main").try(:[],"*")
                commons.edit(title: CGI.unescape(p.descriptionurl.split("/")[4]), text: text, summary: "Fixing WLM date")
                sleep(10)
            end
        end
    end

    task :add_banner => :environment do
        commons = MediawikiApi::Client.new("https://commons.wikimedia.org/w/api.php")
        commons.log_in(ENV["USERNAME"], ENV["PASSWORD"])
        Photo.where(created_at: Date.parse("1 aug 2021")..Date.parse("5 sep 2021")).each do |p|
            next if p.descriptionurl.nil?
            puts "#{p.title} - Doing #{p.descriptionurl.split("/")[4]}"
            wikitext = commons.query prop: :revisions, titles: p.descriptionurl.split("/")[4], rvprop: :content, rvslots: "*"
            next if wikitext.data["pages"].first.try(:[], 1).try(:[], "revisions").try(:[], 0).try(:[],"slots").try(:[], "main").try(:[],"*").nil?
            text = String.new(wikitext.data["pages"].first.try(:[], 1).try(:[], "revisions").try(:[], 0).try(:[],"slots").try(:[], "main").try(:[],"*"))
            unless text.match?(/{{Load via app WLM\.it\|year=2021}}/i)
                text.gsub!(/\|description=(.+)/i, '|description=\1{{Load via app WLM.it|year=2021}}')
                commons.edit(title: CGI.unescape(p.descriptionurl.split("/")[4]), text: text, summary: "Adding WLM template") unless text == wikitext.data["pages"].first[1]["revisions"][0]["slots"]["main"]["*"]
            end
            sleep(10)
        end
    end
end