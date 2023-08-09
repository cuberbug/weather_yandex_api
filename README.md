# Виджет погоды с использованием API Яндекса

На просторах интернета мне попалась [статья](https://zhaik.su/667/yandeks-pogoda-na-ubuntu) с вот таким виджетом:

![screenshot](https://s8d7.turboimg.net/sp/1ce460999585657795bb3b7d3f46b3e0/4444516.png "Пример работы виджета, можно открыть в фуллскрин")

Хочу поделиться с вами этим виджетом и рассказать как установить его на Ubuntu. Копирование и модификация проекта приветствуется!

Если захочется попробовать, то смело клонируйте репозиторий и переходите к инструкции по установке.

Или можете ознакомиться с подробностями [о проекте](#about).


## Установка


### Подготовительный этап

Сам виджет - это скрипт и конфиг файл для [Conky](https://github.com/brndnmtthws/conky) - программы с очень широким функционалом для мониторинга ресурсов ПК, с её установки и начнём.
Для этого выполним в консоли команду:
```BASH
sudo apt-get install conky
```

Так же рекомендуется иметь установленный [Inkscape](https://inkscape.org/)
```BASH
sudo apt install inkscape
```
```BASH
sudo apt install libcanberra-gtk-module libcanberra-gtk3-module
```


### Взаимодействие с реппозиторием

> Если есть желание модифицировать виджет самостоятельно, то не забудьте сделать форк проекта и клонировать уже собственный репозиторий.

Клонируем (или скачиваем архивом) репозиторий в любое удобное место, нам из него понадобятся папки `weather`, `conky_config` и `GE_Inspira`.

Начнём со шрифтов.
* Устанавливаем все шрифты из папки `GE_Inspira`

Далее переходим к папке `conky_config`
* Копируем из неё файл `.conkyrc` в свою домашнюю директорию, этот конфиг - основа виджета, которая отвечает за его 
  внешний вид и функциональность (нажмите сочетание клавиш `Ctrl + H` если проводник не отображает скрытые файлы).
* Открываем `.conkyrc`, находим в нём через поиск по файлу (`Ctrl + F`) наименование сетевого оборудования `wlo1` и сверяемся с его названием на своей машине, проверить которое можно командой:
    ```BASH
    ip a
    ```
    ![screenshot](https://s8d4.turboimg.net/sp/197339308b8eabd13b2a5c63908fa0b4/4110919.png)
  
  если название не совпадает, то заменяйте на указанное в терминале.

  В самом конце конфига есть строка с городом, сейчас там написано "Москва". Замените на свой город или любое другое слово.

Далее к папке `weather`
* В ней находится скрипт, который общается с API и записывает полученные данные во временные файлы `full.txt` и `fact.txt`, с которыми потом взаимодействует Conky через конфиг. Папку копируем в домашнюю директорию.
> Если хочется хранить её в другом месте, то придётся в `.conkyrc` переписать адреса для файлов `full.txt` и `fact.txt` на актуальные.


### Подготовка API

Отвлечёмся пока от виджета и подготовим для его дальнейшей настройки API:
* Заходим в [кабиинет разработчика](https://developer.tech.yandex.ru/services) и подключаем API Яндекс.Погоды. Если вы пользуетесь сервисом впервые, то можете выбрать тариф "Тестовый" - у него более широкий функционал и лимит запросов 5к в сутки, что как раз отлично подходит для тестов, однако подключить его можно только 1 раз и только на 1 месяц. Скрипт настраивается в зависимости от тарифа, но об этом позже.
  
  ![screenshot](https://s8d5.turboimg.net/sp/7f9213973d8925faa2223ca98690cba6/2436993.png)
  
  ![screenshot](https://s8d2.turboimg.net/sp/08a4017f5ba13e122e07e74b76055844/7475884.png)

  Бесплатный тариф ограничен 50 запросами в сутки. Обратите внимание на то, какой конкретно тариф у вас работает: после подключения может автоматически активироваться "Тестовый", даже если вы выбирали "Погода на вашем сайте"
  
  ![screenshot](https://s8d5.turboimg.net/sp/086b59ddd8a371ba22cdc2fa6c771943/9648376.png "Пример внешнего вида страницы с подключенным API")
* Далее переходим в [документацию](https://yandex.ru/dev/weather/doc/dg/concepts/about.html), кликаем на боковой панели "Фактическое значение и прогноз погоды" и выбираем инфо о том тарифе, который у вас сейчас активен:
  
  ![screenshot](https://s8d2.turboimg.net/sp/ea79b8d853b01c7053e98b834f535573/1791050.png)
* В самой документации в первую очередь обратите внимание на блоки "Формат запроса" и "Формат ответа" - они отличаются в зависимости от тарифа:
  
  ![screenshot](https://s8d4.turboimg.net/sp/b3cb7db676262b562d85825db59bdaf6/5472445.png "Выделена отливающаяся часть")
  
  ![screenshot](https://s8d8.turboimg.net/sp/e97171ad95ec750353d47c65655c1f4b/1023191.png "Выделена отливающаяся часть")


### Настройка скрипта

Вернёмся к настройке виджета.
Сейчас нам нужен файл скрипта `weather.sh`, который находится в папке `weather`. Открываем его и видим подготовленную мной цензуру:

![screenshot](https://s8d2.turboimg.net/sp/c8c77d10bee556b704d4692c4f744c33/6720133.png "¯\\_(ツ)_/¯")

Все отмеченные `xxxxxxx` на скрине места нужно заполнить соответствующими данными из [кабиинета разработчика](https://developer.tech.yandex.ru/services) и [документации](https://yandex.ru/dev/weather/doc/dg/concepts/about.html):
* В поле `API='X-Yandex-API-Key: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';` вставляем свой ключ API
* `URL` запроса корректируем в зависимости от вашего тарифа, в `lat=55.765426&lon=37.605703` заменяем числа на ваши координаты, взять их можно, например, с [Яндекс Карт](https://yandex.ru/maps/)
* В строке `grep -Pom1 '(?s)((?<="fact":{)(.*?)(?=(,"xxxxxxxxx")))' ~/weather/full.txt > ~/weather/fact.txt;` подставьте соответствующее вашему тарифу название объекта из блока "Формат ответа" в документации

Вы великолепны!🎉 Осталось совсем немного.

Убедитесь, что в параметрах скрипта отмечено "Исполняемый как приложение" и запускайте "Startup Applications" для добавления `weather.sh` в список выполнения: выбираем `add`, в появившемся окне жмём `Browse...` и указываем путь до скрипта `weather.sh` нажав на `Open` после выбора файла. Название и описание не принципиально.

![screenshot](https://s8d8.turboimg.net/sp/6912f0d322793bf932efa9dc9d8be794/2766546.png "Окно Startup Applications")

"Startup Applications" можно запустить и через консоль:
```BASH
gnome-session-properties
```

> Опционально:
> * Изначално предлагалось использовать в "Startup Applications" файл `conky_start.sh` в качестве сценария для автозапуска Conky, но у меня не получилось добиться его работы, поэтому Conky я пока что запускаю вручную при каждом старте системы. Настраивается аналогично `weather.sh`


### Проверка

Для уверенности в том, что всё работает, запустите скрипт вручную выбрав "Запустить как приложение". После запуска скрипта рядом с ним должны появится файлы `full.txt` и `fact.txt`. Если они заполнены информацией из объектов API, то всё отлично, поехали дальше. Если же файлов нет или они появились, но остались пустыми, то проверьте не было ли ошибок во время заполнения мест, помеченных `xxxxxxx`.

Для проверки работы виджета можно запустить Conky вручную: он сразу должен подтянуть данные из файлов и отобразить погоду на момент ручного запуска `weather.sh`.


### Планировщик

> Если Cron не установлен, то выполнить установку можно командой:
> ```BASH
> sudo apt install cron
> ```

Запускаем Cron следующей командой:
```BASH
crontab -e
```
При первом запуске крон может предложить на выбор как себя запустить - выбирайте первый вариант. Далее откроется окно с инструкцией в комментариях, опускайтесь в самый низ и добавляйте в конце команду с адресом к `weather.sh`

![screenshot](https://s8d6.turboimg.net/sp/952493469ca734a2d30a06d2d08519ee/2667905.png "Окно редактирования Cron")
```BASH
*/30 * * * * ~/weather/weather.sh
```
Адрес может быть прямым, как на скрине, или относительным - как в форме. Работать должны оба варианта, просто в первом придётся указывать уникальный, для ваших настроек пользователя, адрес. Если переводить команду дословно, то получится: *выполнять каждые 30 минут скрипт по указанному адресу.* Обновляться можно и чаще, но не забывайте об ограничении на количество запросов в сутки для API.


## <a id="about">О проекте</a>

Цель проекта: рассказать о существовании классного виджета и расширить его функциональность.

### История изменений и планы по развитию

> + ...
> + `v23.08.05` - Создание базовой версии проекта.
>
> ---
>
> - [x] Создание базовой версии проекта.
> - [ ] Получение фидбэка по мануалу.
> - [ ] Доработка файла конфигурации `.conkyrc`
> - [ ] Перенос взаимодействия с API на чистый Python.
> - [ ] Расширение функционала виджета.


### Дополнительно

---

Базовая версия проекта создана с использованием статьи ["Яндекс погода на Ubuntu"](https://zhaik.su/667/yandeks-pogoda-na-ubuntu) и её материалов.

---