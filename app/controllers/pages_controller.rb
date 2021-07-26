class PagesController < ApplicationController
  def uhm
    @language = session[:language]
  end
  
  def faq
    if params[:language] == "it"
      render "faq/it"
    else
      render "faq/en"
    end
  end
end
