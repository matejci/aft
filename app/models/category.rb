# frozen_string_literal: true

class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :hashtags, dependent: :nullify
  has_many :posts, dependent: :nullify

  field :name, type: String
  field :link, type: String
  field :status, type: Boolean, default: true

  index link: 1

  scope :active, -> { where(status: true) }
  scope :tutorial, -> { where(link: 'aft-tutorial') }
  scope :without_tutorial, -> { where.not(link: 'aft-tutorial') }

  validates :name, presence: { message: 'Required' }
  validates :link, presence: { message: 'Required' }, on: :update

  validate :filter_name, on: :create, unless: proc { |c| c.name.nil? }
  validate :set_parameterize_link, on: :create, unless: proc { |c| c.name.nil? }
  validate :update_parameterize_link, on: :update

  attr_accessor :icon, :filter_active_icon, :filter_inactive_icon

  def filter_name
    self.name = name.titleize
  end

  def set_parameterize_link
    # turn category name into link
    parameterized_link = name.downcase.parameterize
    increment_link(parameterized_link)
  end

  def update_parameterize_link
    if name_changed?
      parameterized_link = name.downcase.parameterize
      increment_link(parameterized_link)
    elsif link_changed?
      parameterized_link = link
      increment_link(parameterized_link)
    end
  end

  def self.aft_tutorial_category
    Rails.cache.fetch('aft-tutorial-category') do
      find_by(link: 'aft-tutorial')
    end
  end

  def increment_link(parameterized_link)
    # if same category link exists add a number until unique
    num = 0
    self.link = loop do
      incremental_link = if num.zero?
        parameterized_link
      else
        "#{parameterized_link}-#{num}"
      end

      num += 1

      break incremental_link unless Category.where(link: incremental_link).exists?
    end
  end
end
