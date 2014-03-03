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
      facet = params[:facet]
      facet = "" if facet.nil?
      @sort = params[:sort]
      @sort = "" if @sort.nil?
      
      @filters = facet.split(",")
      @index = "_all"
      
      unless @filters.empty?
        @filters.each do |filter|
          if filter.match(/^index\:(.*)/)
            @index = $1
          end
        end
        @filters.delete_if {|x| x.match(/^index\:/)}
      end
      
      case @sort
      when "relevant"
        sort = "_score,date:desc"
      when "recent"
        sort = "date:desc"
      when "earliest"
        sort = "date"
      end
      
      @results = @search.search(@query, @index, @start, @filters, sort)
      @total = @results["hits"]["total"]
      
      haml :index
    end
    
    get "/ua" do
      request.user_agent
    end
  end
end