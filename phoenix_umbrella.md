# Umbrella Apps

1. `mix new app_name --umbrella`
1. move chat server project into `/apps`
1. `mix phoenix.new chat_web`

These two apps are now living in the same umbrella app. They can reference each
other's functions.