#encoding: utf-8

require 'rest-client'
require 'json'

module LHC
  class Searcher
    def initialize(host, port=nil)
      if port
        @url = "#{host}:#{port}"
      else
        @url = "#{host}"
      end
    end
    
    def search(query_string, index_string="_all", from=0, filters=nil)
      sort = "_score,date:desc"
      filter = {:value => {}}
      
      if filters
        filter = interpret_filter(filters)
      end
      
      res = RestClient.post "#{@url}/#{index_string}/_search?pretty=true&sort=#{sort}", \
      { \
        :query => { :query_string => { :query => "#{query_string}" }}, \
        :facets => { \
          :members => {:terms => {:field => "members"} }, \
          :components => {:terms => {:field => "hansard_component"} } \
        }, \
        :fields => ["url", "members", "title", "hansard_ref", "date", "chair", "number", "hansard_component", "question_type"], \
        :highlight => { :fields => { :text => { :fragment_size => 150, :number_of_fragments => 3 } } }, \
        :filter => filter[:value], \
        :from => from
      }.to_json, :content_type => :json
      
      JSON.parse(res.body)
    end
    
    
    private
    
    def interpret_filter(filters)
      filter_terms = []
      filter = {}
      filters = [filters] if filters.is_a?(String)
      filters.each do |filter_term|
        term, value = filter_term.split(":")
        term = "hansard_component" if term == "component"
        if term
          filter_terms << {:term => {term => value} }
        end
      end
      
      unless filter_terms.empty?
        filter = {:value => { :query => filter_terms[0] } }
      else
        filter[:value] = {}
      end
      
      filter
    end
  end
end