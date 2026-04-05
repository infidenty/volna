# IMS Fix - Volna Crimea (Pixel 7a)

Magisk-модуль для принудительной активации IMS/VoLTE на операторе **Волна** (MCC 250, MNC 60) для Google Pixel 7a (lynx) с Android 17 Beta 3.

## Проблема

Pixel 7a не регистрирует IMS на сети Волна в Крыму. Причина:
- Оператор 250-60 отсутствует в whitelist Google Pixel
- CarrierConfigManager не возвращает VoLTE-флаги
- IMS-стек фреймворка не запускается
- VonR отключён на слоте 0

## Решение

Модуль выполняет:
1. Устанавливает `ro.carrier = volna` (вместо `unknown`)
2. Создаёт CarrierConfig XML для MCC 250 / MNC 60 с VoLTE/VoWiFi флагами
3. Включает VonR на слоте 0 (`is_vonr_enabled_0=1`)
4. Создаёт dedicated IMS APN если отсутствует
5. Добавляет тип `ims` к текущему preferred APN
6. Перезапускает IMS-стек через system broadcasts
7. Форсирует binding pixel_ims_module

## Установка

1. Скачайте `fix_ims_volna_v2.0.zip` из Releases
2. Установите через Magisk → Modules → Install from storage
3. **Перезагрузите устройство**
4. Подождите 60 секунд после загрузки

## Проверка

```bash
# Статус IMS
getprop ro.carrier          # volna
getprop persist.radio.is_vonr_enabled_0  # 1

# Логи
logcat -b radio -d -t 200 | grep -iE "ims|register|sip|volte"

# Меню телефона
*#*#4636#*#* → Phone → IMS Status
```

## Ограничения

- Не решает серверный `403 Forbidden` / `401 Unauthorized` от SIP-сервера оператора
- Не решает блокировку по IMEI
- Если Samsung S.LSI RIL не поддерживает IMS для неизвестного оператора — модуль не поможет (нужен кастомный RIL)

## Требования

- Google Pixel 7a (lynx)
- Android 14+ (тестировано на Android 17 Beta 3 / SDK 37)
- Magisk Kitsune / KernelSU / AP
- SIM-карта Волна (250-60)

## Структура

```
fix_ims_volna_v2/
├── module.prop        # Метаданные модуля
├── system.prop        # IMS/VoLTE свойства
├── post-fs-data.sh    # Carrier config + props (ранний boot)
├── service.sh         # Перезапуск IMS + APN fix (поздний boot)
└── customize.sh       # Проверки при установке
```

## Сборка из исходников

```bash
chmod 755 post-fs-data.sh service.sh customize.sh
zip -r ims_volna.zip . -x ".*" -x "__MACOSX/*" -x "README.md" -x ".git/*"
```

## Автор

[infidenty](https://github.com/infidenty)
