# frozen_string_literal: true

# in minutes
CACHE_EXPIRATION = {
  profile_feed: 60,
  home: 30,
  discover: 60,
  explore: 60,
  search_index: 60
}.freeze

KNOWN_USER_AGENTS = ['Googlebot',
                     'Bingbot',
                     'Slurp',
                     'Twitterbot',
                     'LinkedInBot',
                     'Slackbot-LinkExpanding 1.0 (+https://api.slack.com/robots)',
                     'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)',
                     'facebookexternalhit/1.1',
                     'PayPal'].freeze

PER_PAGE = {
  home_feed: 12,
  discover_feed: 12,
  profile_feed: 12,
  explore_feed: 12,
  lb_users: 51,
  lb_posts: 12,
  search_hashtags: 24,
  search_index_users: 8,
  search_index_posts: 12,
  bookmarks: 15,
  follows: 36,
  messages: 20
}.freeze

MAX_CURATED_ITEMS = 20

TAKKO_OFFICIAL_ACCOUNTS = %w[AppForTeachers davidchoi VictoriaChoi Samiam apple mbrajsa matejci].freeze

DEFAULT_PUSH_NOTIFICATIONS_SETTINGS = {
  upvoted: 'everyone',
  added_takko: 'everyone',
  commented: 'everyone',
  mentioned: 'everyone',
  followed: 'on',
  payout: 'off',
  followee_posted: 'off'
}.freeze

EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i.freeze
