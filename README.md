# gentoo_postinstall
Добавление пользователя, установка паролей, автозапуск служб, настройка локалей.


После компиляции Gentoo для меня много времени занимает настройка вручную.
Подготовил небольшой скрипт, который настроит требуемые мне параметры во время нахождения в оболочке chroot, создаст пользователя и после первого логина продолжит работу.


Вы тоже можете им воспользоваться. Вверху кода указаны переменные, которые вы можете изменить/закомментировать по своему усмотению для установки требуемых сервисов, имени пользователя.


