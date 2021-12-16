# frozen_string_literal: true

class ApiConstraints
  attr_reader :version

  def initialize(version:)
    @version = version
  end

  def matches?(req)
    return true if version.zero? && req.headers['X-API-VERSION'].blank?

    req.headers['X-API-VERSION'] == "api.appforteachers.v#{version}"
  end
end
