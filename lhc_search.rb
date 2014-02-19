require 'sinatra/base'

require "./lib/searcher"

module LHC
  class Search < Sinatra::Base
    # start the server if ruby file executed directly
    run! if app_file == $0
    
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
      
      require "./helpers/result_helpers"
    end
    
    before do
      @search = Searcher.new("http://localhost", "9200")
    end
    
    get "/" do
      @query = params[:q]
      @start = params[:start].to_i
      
      @results = @search.search(@query, "commons_hansard", @start)
      @total = @results["hits"]["total"]
      
      haml :index
    end
  end
end