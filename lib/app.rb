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
    def get_all_links
      @links = DB[:Links].all
    end
  end

  not_found do
    '404'
  end

  get '/' do
    get_all_links
    slim :index
  end

  # #POST - add link

  # #GET - form with new link

  # #GET - homepage - get all links and form for adding new link

  # #DELETE - delete link

  # #GET - get links statistics

  # #GET - get form for edit link informations

  # #PUT - edit link information

  # #GET - refresh all links statistics iwth download_stats

end
