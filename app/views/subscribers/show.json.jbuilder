
json.extract! @subscriber, :id, :firstName, :lastName, :email, :phone, :link

json.position number_with_delimiter(@subscriber.position)