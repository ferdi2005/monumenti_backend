class PagesController < ApplicationController
  def uhm
  end
  
  def faq
    if params[:language] == "it"
      render "faq/it"
    else
      render "faq/en"
    end
  end
end
