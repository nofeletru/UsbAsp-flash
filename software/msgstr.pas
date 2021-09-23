unit msgstr;

{$mode objfpc}{$H+}

interface

resourcestring
  STR_CHECK_SETTINGS     = 'Проверьте настройки';
  STR_READING_FLASH      = 'Читаю флэшку...';
  STR_WRITING_FLASH      = 'Записываю флэшку...';
  STR_WRITING_FLASH_WCHK = 'Записываю флэшку с проверкой...';
  STR_CONNECTION_ERROR   = 'Ошибка подключения к ';
  STR_SET_SPEED_ERROR    = 'Ошибка установки скорости SPI';
  STR_WRONG_BYTES_READ   = 'Количество прочитанных байт не равно размеру флэшки';
  STR_WRONG_BYTES_WRITE  = 'Количество записанных байт не равно размеру флэшки';
  STR_WRONG_FILE_SIZE    = 'Размер файла больше размера чипа';
  STR_ERASING_FLASH      = 'Стираю флэшку...';
  STR_DONE               = 'Готово';
  STR_BLOCK_EN           = 'Возможно включена защита на запись. Нажмите кнопку "Снять защиту" и сверьтесь с даташитом';
  STR_VERIFY_ERROR       = 'Ошибка сравнения по адресу: ';
  STR_VERIFY             = 'Проверяю флэшку...';
  STR_TIME               = 'Время выполнения: ';
  STR_USER_CANCEL        = 'Прервано пользователем';
  STR_NO_EEPROM_SUPPORT  = 'Данная версия прошивки не поддерживается!';
  STR_MINI_EEPROM_SUPPORT= 'Данная версия прошивки не поддерживает I2C и MW!';
  STR_I2C_NO_ANSWER      = 'Микросхема не отвечает';
  STR_COMBO_WARN         = 'Чип будет стерт и перезаписан. Продолжить?';
  STR_SEARCH_HEX         = 'Поиск HEX значения';
  STR_GOTO_ADDR          = 'Перейти по адресу';
  STR_NEW_SREG           = 'Стало Sreg: ';
  STR_OLD_SREG           = 'Было Sreg: ';
  STR_START_WRITE        = 'Начать запись?';
  STR_START_ERASE        = 'Точно стереть чип?';
  STR_45PAGE_STD         = 'Установлен стандартный размер страницы';
  STR_45PAGE_POWEROF2    = 'Установлен размер страницы кратный двум!';
  STR_ID_UNKNOWN         = '(Неизвестно)';
  STR_SPECIFY_HEX        = 'Укажите шестнадцатеричные числа';
  STR_NOT_FOUND_HEX      = 'Значение не найдено';
  STR_USB_TIMEOUT        = 'USB_control_msg отвалился по таймауту!';
  STR_SIZE               = 'Размер: ';
  STR_CHANGED            = 'Изменен';
  STR_CURR_HW            = 'Используется программатор: ';
  STR_USING_SCRIPT       = 'Используется скрипт: ';
  STR_DLG_SAVEFILE       = 'Сохранить изменения?';
  STR_DLG_FILECHGD       = 'файл изменён';
  STR_SCRIPT_NO_SECTION  = 'Нет секции: ';
  STR_SCRIPT_SEL_SECTION = 'Выберите секцию';
  STR_SCRIPT_RUN_SECTION = 'Выполняется секция: ';
  STR_ERASE_NOTICE       = 'Процесс может длиться больше минуты на больших флешках!';

implementation

end.

