
# json.array! @subscribers, partial: 'subscribers/subscriber', as: :subscriber

json.set! :subscribers do
  json.array! @subscribers do |subscriber|
    json.extract! subscriber, :id, :firstName, :lastName, :email, :age, :link, :invite, :status,
                              :mobile_device, :ip_address, :user_agent, :position, :position_growth,
                              :queue, :status, :email_delivery_status, :updated_at

    json.set! :created_at, subscriber.created_at.strftime("%b %e, %Y - %l:%M%P").to_s
    unless subscriber.email_delivery_date.nil?
      json.set! :email_delivery_date, subscriber.email_delivery_date.strftime("%b %e, %Y - %l:%M%P").to_s
    else
      json.set! :email_delivery_date, nil
    end

    unless subscriber.parent_id.nil?
      referred_subscriber = Subscriber.find(subscriber.parent_id)
      json.set! :referred_by, referred_subscriber.email
    else
      json.set! :referred_by, nil
    end
  end
end

json.set! :subscribersTotal, @subscribers.total_count
json.set! :subscribersTotalPages, @subscribers.total_pages
