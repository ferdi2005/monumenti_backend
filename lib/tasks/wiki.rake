require 'mediawiki_api'
namespace :wiki do
    task :amend_date do
        commons = MediawikiApi::Client.new("https://commons.wikimedia.org/w/api.php")
        commons.log_in(ENV["USERNAME"], ENV["PASSWORD"])
        Photo.where(date: Date.parse("1 jan 2000")..Date.parse("31 dec 2020")) do |p|
            puts "Doing #{p.descriptionurl.split("/")[4]}"
            wikitext = commons.query prop: :revisions, titles: p.descriptionurl.split("/")[4], rvprop: :content, rvslots: "*"
            wixitext.gsub!(/{{Monumento italiano\|([\w\d]+)\|anno=20[01][023456789]}}/i, "{{Monumento italiano|\1|anno=2021}}")
            wixitext.gsub!(/{{Wiki Loves Monuments 20[01][023456789]\|it}}/i, "{{Wiki Loves Monuments 2021|it}}")
            wikitext.gsub!(/{{Load via app WLM\.it\|year=20[01][023456789]}}/i, "{{Load via app WLM.it|year=2021}}")

            commons.edit(title: p.descriptionurl.split("/")[4], text: wikitext, summary: "Fixing WLM date")
        end
        sleep(30)
    end

    task :add_banner do
        Photo.where(created_at: Date.parse("1 aug 2021")..Date.parse("5 sep 2021")).each do |p|
            puts "Doing #{p.descriptionurl.split("/")[4]}"
            wikitext = commons.query prop: :revisions, titles: p.descriptionurl.split("/")[4], rvprop: :content, rvslots: "*"
            unless p.match?(/{{Load via app WLM\.it\|year=2021}}/i)
                wikitext.gsub!(/\|description=(.+)/i, "|description=\1{{Load via app WLM.it|year=2021}}")
                commons.edit(title: p.descriptionurl.split("/")[4], text: wikitext, summary: "Adding WLM template")
            end
        end
        sleep(30)
    end
end