# Oshiete-Karen-bot

## Install

* MySQL (>= 5.5)
* Ruby (>= 2.0.0)

and

```
bundle install
```

## Run the bot

1. Set `client_secrets.json` to `./bot` (you should get this from [Google API Console]( https://www.google.co.jp/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&cad=rja&uact=8&ved=0ahUKEwjd2cvZs8HQAhXDm5QKHTFlDmkQFggiMAE&url=https%3A%2F%2Fconsole.developers.google.com%2F&usg=AFQjCNF0eH059mv86nMIlRmfsf42kde-wA&sig2=bzePGZK81Fq22TJ4EFOMHw) on your own).
2. Rename `config.yaml.template` to `config.yaml` and fulfill parameters along your environment.

and

```
bundle exec rackup
```
