# frozen_string_literal: true

module Twitter
  module TwitterText
    class Regex
      REGEXEN[:valid_mention_or_list] = /
        (#{REGEXEN[:valid_mention_preceding_chars]}) # $1: Preceeding character
        (#{REGEXEN[:at_signs]})                      # $2: At mark
        (\w{2,30})                                   # $3: username (2+ to match usernames before the length validation)
      /iox
    end
  end
end
