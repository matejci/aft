# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :web_app_token_init, :validate_app_token, :set_current_user, only: [:apple_app_site_association, :api_docs, :hls]

  def index
    case request.server_name
    when 'www.recipetube.me', 'recipetube.me'
      redirect_to campaigns_recipetube_path
    when 'www.cryptotube.me', 'cryptotube.me'
      redirect_to campaigns_cryptotube_path
    when 'www.kpopfam.com', 'kpopfam.com'
      redirect_to campaigns_kpopfam_path
    end
  end

  def apple_app_site_association
    @apple_apps = {
      applinks: {
        apps: [],
        details: [
          {
            appID: ENV['APPLE_APP_ID'],
            components: [
              {
                '/': '/p/*'
              },
              {
                '/': '/profiles/*'
              },
              {
                '/': '//profiles/*'
              },
              {
                '/': '/terms',
                exclude: true
              },
              {
                '/': '/privacy',
                exclude: true
              }
            ],
            paths: [
              '/p/*',
              '/profiles/*',
              '//profiles/*',
              'NOT /terms',
              'NOT /privacy'
            ]
          }
        ],
        webcredentials: {
          apps: [
            ENV['APPLE_APP_ID']
          ]
        }
      }
    }

    render 'apple_app_site_association.json'
  end

  def tutorial
    @collection = TutorialService.new(page_num: params[:page]).call
  end

  def env
    respond_to :js
  end

  def hls
    render layout: false
  end

  def api_docs
    html = Aws::S3::Object.new(ENV['API_DOCS_BUCKET'], 'api_doc.html', region: 'us-west-1').get.body.string

    render html: html.html_safe, content_type: 'text/html' # rubocop: disable Rails/OutputSafety
  end
end
