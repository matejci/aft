class EventConstraint
  def self.matches?(request)
    ViewTracking::ACTION_STATUS.key?(request.parameters['event'])
  end
end
