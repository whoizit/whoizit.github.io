+++
title = "Алеша-интернет: 2. Twitch API"
date = 2022-01-25
+++

Продолжаем решать проблемы [Алёши](https://twitch.tv/ucsm)

В чём проблема? Елки-палки, Алёше нужно в *своём интернете* показывать все онлайн каналы, на которые он подписан. 

Если бы Алёша читал официальную документацию, он бы сделал три вывода:
1. Twitch API v5 [устарело](https://dev.twitch.tv/docs/v5) и скоро откиснет, а вместо него необходимо использовать [Helix API](https://dev.twitch.tv/docs/api/reference/).
Определить что пользуешься правильным API просто, в ссылке на API должно быть слово *helix* и не должно быть слова *kraken*
2. Его задачу решает метод [Get Followed Streams](https://dev.twitch.tv/docs/api/reference#get-followed-streams), но перед тем как ей пользоваться, нужно узнать свой ID через метод [Get Users](https://dev.twitch.tv/docs/api/reference#get-users). Чтобы не спрашивать свой ID постоянно, его можно и нужно захардкодить
3. Метод *Get Followed Stream* требует OAuth ключа, я получал его через `twitch-cli`, но можно получить и через pyTwitchAPI. Ещё необходимо реализовать обновление ключа, чтобы не делать этого вручную каждый месяц.

Я по приколу реализовал это на Dart'e, а данные авторизации получал из `twitch-cli`, Но на Python это будет так-же быстро
для получения OAuth токена с разрешениями для нужного нам метода сделаем: 
```sh
$ twitch token -u -s 'user:read:follows'
```
```dart
// 2.dart
import 'dart:convert';
import 'package:dotenv/dotenv.dart' show load, env;
import 'package:http/http.dart';
import 'package:pretty_json/pretty_json.dart';

void main(List<String> arguments) async {
  load('${env['HOME']}/.config/twitch-cli/.twitch-cli.env');

  final headers = {
    'Authorization': 'Bearer ${env['ACCESSTOKEN']}',
    'Client-Id': env['CLIENTID'] ?? 'fuck'
  };
  var r = await get(Uri.parse('https://api.twitch.tv/helix/users?login=ne_noj'),
      headers: headers);
  final userId = jsonDecode(r.body)['data'][0]['id'];

  r = await get(
      Uri.parse('https://api.twitch.tv/helix/streams/followed?user_id=$userId'),
      headers: headers);
  printPrettyJson(jsonDecode(r.body)['data'], indent: 2);
}
```
```sh
# Запустим собранный бинарник
~/tmp > time 2.exe | rg 'user_name|type|title'
    "user_name": "pokimane",
    "type": "live",
    "title": "heeeellllloooooooo 🥰 sus lobby w/ rae, corpse, toast, sykkuno, tina, fuslie, emma, karl, wendy",
    "user_name": "fuslie",
    "type": "live",
    "title": "AMONG US!? I'M FEELING A LIL SUSSY TODAY POGGERS ",
    "user_name": "Amouranth",
    "type": "live",
    "title": "DANCING 💦 RAP VIDEO TOMORROW ON MY YOUTUBE CHANNEL --> !YT💦 !s-->my links in chat",
    "user_name": "a_couple_streams",
    "type": "live",
    "title": "live music  |  aeseaes on !Spotify  | !Fever out now",
    "user_name": "calvinthomasmusic",
    "type": "live",
    "title": "It's The 1k Subs/25K Follower Stream! | !giveaway !bumptune !discord !ep !tip",
    "user_name": "Sweet_Anita",
    "type": "live",
    "title": "VIDEOS + MEMES THAT TICKLE MY PICKLE | !corsair !elgato !discord !merch !charity #ad",
    "user_name": "Knut",
    "type": "live",
    "title": "FOLLOW instagram.com/knutspild !nordvpn #ad",
    "user_name": "jakenbakeLIVE",
    "type": "live",
    "title": "IRL LA THROWING JOHN ELWAY'S NERF VORTEX *PATENT PENDING* - !YouTube !Socials",
    "user_name": "FoxenKin",
    "type": "live",
    "title": "❤️ COME GET COZY WITH ME❤️ !S for Links ❤️   | EN + FR | New Video !YT",
    "user_name": "MuhanJan",
    "type": "live",
    "title": "СПЛЮ НА СТРИМЕ - проснусь ТОЛЬКО на 30К фоллоу, ПОМОГИТЕ - уснул ~20:10 мск",
    "user_name": "ChaBrikk",
    "type": "live",
    "title": "Отдыхаем ,  общаемся ... ",
    "user_name": "sienimiili",
    "type": "live",
    "title": "🎉 5 YEAR PARTNERVERSARY 🎉 24h stream ♥ kudoboard time~",
    "user_name": "ninibae",
    "type": "live",
    "title": "💃 Shy Korean nini 💪  💓 uWu 💓 [EN/KR] !donate",
    "user_name": "WELOVEGAMES",
    "type": "live",
    "title": "Приятных выходных | !tg",
    "user_name": "kkyumingming",
    "type": "live",
    "title": "scuffed YOGA stream : actural YOGA",
    "user_name": "CookSux",
    "type": "live",
    "title": "A Little Bit of NY Recap Day 2 | $2TTS | !Kingdoms #AD",
    "user_name": "Monstercat",
    "type": "live",
    "title": "Non Stop Music - Monstercat TV 🎶",
    "user_name": "藍仙子儒儒",
    "type": "live",
    "title": "【儒儒💕】多人✨戰神之路♡有你有我 ➤ 歡迎+群💙 !dc ٩(๑´3｀๑)۶",
    "user_name": "DMITRY_BALE",
    "type": "live",
    "title": "[Повтор] Финал ГОД оф ВАР он ПК, БОЙ! | Стрим #2-3",
    "user_name": "PuppetSouI",
    "type": "live",
    "title": "Hey inhouse tonight apparently (still sick)\n",
    "user_name": "AngryTestie",
    "type": "live",
    "title": "Done for the night just weebing out before bed",
    "user_name": "JulieRyff",
    "type": "live",
    "title": "ヾ( ･ω|  _G O O D_ evening my _L O V E S_ ! !patreon !town ",
    "user_name": "helen_frost",
    "type": "live",
    "title": "Eng/ru \"Elen sila lumen omentielvo\" - something in elvish  ★_★  !link !boosty ",
    "user_name": "clantons",
    "type": "live",
    "title": "New to diz",
    "user_name": "dashainostranka",
    "type": "live",
    "title": "Упфокныткянтртке",
    "user_name": "CateVinelle",
    "type": "live",
    "title": "hey you, click this♡ ",
    "user_name": "lelitiny",
    "type": "live",
    "title": "Хорошего настроения!)",
    "user_name": "NoCopyrightSounds",
    "type": "live",
    "title": "NCS 24/7 Gaming Music Livestream",
    "user_name": "UnikaRai",
    "type": "live",
    "title": "^^💙 | !Юня !звук",
    "user_name": "Evil_genius_Blackhertz",
    "type": "live",
    "title": "Ive never DIED THIS MUCH..",
    "user_name": "Momentine_",
    "type": "live",
    "title": "CG 600 Start - The Grind Never Ends",
```
Время работы программы с двумя запросами - **0.01s**
```sh
2.exe  0.01s user 0.01s system 1% cpu 0.986 total
```
