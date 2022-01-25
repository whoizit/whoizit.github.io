+++
title = "Алёша-интернет: 1. обход защиты Cloudflare"
date = "2022-01-25"
+++

Решаем проблемы [Алёши](https://twitch.tv/ucsm)

Стало интересно почему `curl` спокойно загружает rss фид, а `python-reguests` не может пройти защиту Cloudflare anti-bot page. Стал разбираться и понял что разница лишь в том что `curl` делает *HTTP/2* запрос, а `python-requests` умеет только *HTTP/1.1*.
Решение оказалось простое, использовать библиотеку поддерживающую *HTTP/2*. Одна из таких библиотек для питона это `python-httpx` которая сама по себе работает с `python-h2` для поддержки *HTTP/2*

*(Решение опубликовал на [stackoverflow](https://stackoverflow.com/questions/49087990/python-request-being-blocked-by-cloudflare/70706028#70706028))*

Конечно это не совсем решение, т.к. Cloudflare может прикрыть лавочку в любой момент. Но пока это работает быстро и без костылей.

Но Алёше, *согласись*, ссылка на *stackoverflow* не помогла, ну *елки-палки*, пришлось писать для него пример кода. Feedparser он так и не юзает, парсит там что-то через BeautifulSoup4 и регулярки... Не понимаю зачем, если есть официальный feed.

```sh
$ poetry new alyosha-1
$ cd alyosha-1
$ poetry add httpx -E http2
$ poetry add feedparser
$ poetry shell
$ vim 1.py
```
```python
#!/usr/bin/env python
import httpx
import feedparser

url = 'https://mangalib.me/manga-rss/onepunchman'
client = httpx.Client(http2=True)
response = client.get(url)
feed = feedparser.parse(response.text)

print(feed['entries'][0]['link'])
```
```sh
$ python 1.py
https://mangalib.me/onepunchman/v30/c200
```

В конце, наверное, следует упоминуть, что это работает очень быстро.
