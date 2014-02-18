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
    
    def search(query_string, index_string="_all", from=0)
      res = RestClient.post "#{@url}/#{index_string}/_search?pretty=true", \
      { \
        :query => { :query_string => { :query => "#{query_string}" }}, \
        :facets => {:members => {:terms => {:field => "members"} } }, \
        :fields => ["url", "members", "title", "hansard_ref", "date", "chair", "number", "question_type"], \
        :highlight => { :fields => { :text => { :fragment_size => 150, :number_of_fragments => 3 } } }, \
        :from => from
      }.to_json, :content_type => :json
      
      JSON.parse(res.body)
    end
  end
end