# encoding: utf-8
require 'sequel'
require 'sinatra'
require 'slim'
require 'database'
require_relative './helpers/facebook'

class FacebookStats < Sinatra::Base
  include Facebook
  set :views, './views'
  set :public_folder, './public'
  set :method_override, true

  before do
    @author = 'Tomas'
    @year   = Time.now.year
  end

  helpers do
    def all_links
      @links = DB[:Links].all
    end

    def all_links_and_stats
      @links = DB[:Links].join(:Stats, :link_id => :id).all
    end
  end

  not_found do
    '404'
  end

  # #GET - homepage - get all links and form for adding new link
  get '/' do
    all_links
    slim :index
  end

  # #POST - add link
  post '/links' do
    if params[:url].length > 0
      url_input = params[:url]
      result = Facebook.get_result url_input
      p_key = DB[:Links].insert(:url => url_input, :domain => result['host'])
      DB[:Stats].insert(:link_id => p_key, :like_count => result['like_count'], :share_count => result['share_count'])
    end
    all_links_and_stats
    slim :links
  end

  # #DELETE - delete link
  delete '/link/:id' do |id|
    DB[:Stats].filter(:link_id => id).delete
    DB[:Links].filter(:id => id).delete
    all_links
    slim :index
  end

  # #GET - get links statistics
  get '/link/:id/stats' do |id|
    @stats = DB[:Stats].filter(:link_id => id)
    slim :stats
  end

  # #GET - get form for edit link informations
  get '/link/:id/edit' do |id|
    @link = DB[:Links].first(:id => id)
    slim :link_form
  end

  # #PUT - edit link information
  put '/link/:id' do |id|
    DB[:Links].where('id = ?', id).update(:url => params[:url], :domain => 'domain')
    result = Facebook.get_result params[:url]
    lc = result['like_count']
    sc = result['share_count']
    DB[:Stats].where('link_id = ?', id).update(:like_count => lc, :share_count => sc)
    all_links
    slim :index
  end

  # #GET - refresh all links statistics iwth download_stats
  get '/refresh' do
    DB[:Links].all.each do |link|
      result = Facebook.get_result link[:url]
      lc = result['like_count']
      sc = result['share_count']
      DB[:Stats].where('link_id = ?', link[:id]).update(:like_count => lc, :share_count => sc)
    end
    all_links_and_stats
    slim :links
  end
end
