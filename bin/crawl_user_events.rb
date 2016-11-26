require "./bin/store_user_events"

user_id = ARGV[0]
events = UserEvents.new(user_id)
events.store(events.fetch)
