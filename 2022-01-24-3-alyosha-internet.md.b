+++
title = "Алёша-интернет: 3. Алёша тренит [a]синхронно"
date = 2022-01-24
+++

Продолжаем решать проблемы [Алёши](https://twitch.tv/ucsm)

Алёша сказал что не понимает асинхронность. Написал для него программу тренировок, но он сказал что не понял

```python
import time

### СИНХРОННЫЙ КОД ################################################
def alyosha_trenit_sinhronno(delayu):
    for x in range(1, 4):
        time.sleep(1)
        print(f'{delayu} {x}')
print('Треню синхронно:')
start = time.time()
alyosha_trenit_sinhronno('    Отжимаюсь')
alyosha_trenit_sinhronno('    Пресс качаю')
alyosha_trenit_sinhronno('    Присядаю')
print('Синхронно тренил за {:.2f} сек'.format(time.time() - start))
print('Пошел на работу')
print()

### АСИНХРОННЫЙ КОД ###############################################
import asyncio

async def alyosha_trenit_assinhronno(delayu):
    for x in range(1, 4):
        print(f'{delayu} {x}')
        await asyncio.sleep(1)

async def main():
    print('Треню assинхронно:')
    start = time.time()
    await asyncio.gather(
        alyosha_trenit_assinhronno('    Отжимаюсь'),
        alyosha_trenit_assinhronno('    Пресс качаю'),
        alyosha_trenit_assinhronno('    Присядаю'),
    )
    print('Assинхронно тренил за {:.2f} сек'.format(time.time() - start))
    print('Пошел на работу')

# запуск async loop
asyncio.run(main())
```
Вывод:
```sh
Треню синхронно:
    Отжимаюсь 1
    Отжимаюсь 2
    Отжимаюсь 3
    Пресс качаю 1
    Пресс качаю 2
    Пресс качаю 3
    Присядаю 1
    Присядаю 2
    Присядаю 3
Синхронно тренил за 9.01 сек
Пошел на работу

Треню assинхронно:
    Отжимаюсь 1
    Пресс качаю 1
    Присядаю 1
    Отжимаюсь 2
    Пресс качаю 2
    Присядаю 2
    Отжимаюсь 3
    Пресс качаю 3
    Присядаю 3
Assинхронно тренил за 3.00 сек
Пошел на работу
```
