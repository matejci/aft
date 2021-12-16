# frozen_string_literal: true

module ServiceErrorHandling
  class ServiceError < StandardError; end
  class InstanceError < StandardError
    attr_reader :response_object

    def initialize(response)
      super

      @response_object = response
    end
  end

  def call
    yield
  rescue ServiceError => e
    unprocessable_service(e)
  rescue InstanceError => e
    unprocessable_instance(e)
  end

  private

  def unprocessable_service(error)
    { success: false, message: error.message }
  end

  def unprocessable_instance(error)
    { success: false, errors: error.response_object }
  end
end
