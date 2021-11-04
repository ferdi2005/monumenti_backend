require 'mediawiki_api'
namespace :db do
    task :amend_date => :environment do
        commons = MediawikiApi::Client.new("https://commons.wikimedia.org/w/api.php")
        commons.log_in(ENV["USERNAME"], ENV["PASSWORD"])
        Photo.where(date: Date.parse("1 jan 2000")..Date.parse("31 dec 2020")).each do |p|
            puts "Doing #{p.descriptionurl.split("/")[4]}"
            wikitext = commons.query prop: :revisions, titles: p.descriptionurl.split("/")[4], rvprop: :content, rvslots: "*"
            text = String.new(wikitext.data["pages"].first[1]["revisions"][0]["slots"]["main"]["*"])
            text.gsub!(/{{Monumento italiano\|([\w\d]+)\|anno=20[01][023456789]}}/i, '{{Monumento italiano|\1|anno=2021}}')
            text.gsub!(/{{Wiki Loves Monuments 20[01][023456789]\|it}}/i, "{{Wiki Loves Monuments 2021|it}}")
            text.gsub!(/{{Load via app WLM\.it\|year=20[01][023456789]}}/i, "{{Load via app WLM.it|year=2021}}")
            unless text == wikitext.data["pages"].first[1]["revisions"][0]["slots"]["main"]["*"]
                commons.edit(title: p.descriptionurl.split("/")[4], text: text, summary: "Fixing WLM date")
                sleep(30)
            end
        end
    end

    task :add_banner => :environment do
        commons = MediawikiApi::Client.new("https://commons.wikimedia.org/w/api.php")
        Photo.where(created_at: Date.parse("1 aug 2021")..Date.parse("5 sep 2021")).each do |p|
            puts "Doing #{p.descriptionurl.split("/")[4]}"
            wikitext = commons.query prop: :revisions, titles: p.descriptionurl.split("/")[4], rvprop: :content, rvslots: "*"
            text = String.new(wikitext.data["pages"].first[1]["revisions"][0]["slots"]["main"]["*"])
            unless p.match?(/{{Load via app WLM\.it\|year=2021}}/i)
                text.gsub!(/\|description=(.+)/i, '|description=\1{{Load via app WLM.it|year=2021}}')
                commons.edit(title: p.descriptionurl.split("/")[4], text: text, summary: "Adding WLM template") unless text == wikitext.data["pages"].first[1]["revisions"][0]["slots"]["main"]["*"]
            end
            sleep(30)
        end
    end
end