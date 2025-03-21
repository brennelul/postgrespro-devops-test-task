# postgrespro-devops-test-task

Для запуска необходимо перейти в `src` и запустить bash скрипт `run.sh` (предварительно сделав его исполняемым с помощью `chmod +x run.sh`)

`run.sh` принимает IP-адреса или имя серверов как аргумент, разделитель - запятая. Пример:

```bash
./run.sh 192.168.0.101,192.168.0.102
```
или
```bash
./run.sh 192.168.0.101, 192.168.0.102
```

В самом начале скрипта обьявлены порты, по которым будет подключаться скрипт и ansible к серверам. Если ssh порт отличается от стандартного - следует изменить эти переменные.

Изначально я думал, что лучше будет проверить загруженность сервера вручную (через скрипт), набросал простую реализацию этого, а потом решил, что этим все же будет заниматься плейбук, но наработки оставил.

Когда начал писать роль для выявления менее загруженного сервера, возник вопрос - как факт, который был объявлен внутри одного хоста использовать везде? Ведь scope этих фактов ограничевается хостом, на котором мы выполняем задачу, а нормального inventory файла с обьявленными хостами нет, так как мы передаем адреса хостов как флаг. В итоге с помощью `delegate_to` и `delegate_facts` по сути передаю эту информацию на localhost, и уже с помощью `hostvars` использую факты в других ролях.

По поводу роли `postgres-server` - я реализовал rescue, который удаляет зависимости и postgres если что то пошло не так, а также все конфигурационные файлы с базами данных (папок pgsql и postgresql (эти строчки на всякий случай закомментированы)). Не знаю, является ли это корректным способом очистки при возникновении проблем.

Роль `port-forwarding` - если установлен firewalld (установлен по умолчанию в AlmaLinux 9.5), то добавляет правило для postgres. На Debian последней версии (12.9.0), как я понял, ни firewalld, ни ufw, ни iptables не установлены по умолчанию, так что никаких изменений по идее не нужно совершать.

Еще написал роль `postgres-client` - устанавливает postgres на второй сервер и выполняет с него SELECT 1, чтобы точно убедиться, что все настроенно корректно.

Возникла проблема, когда сервер на Debian становился целевым, на него все корректно устанавливалась, но почему то доступ к порту 5432 из вне появлялся не сразу, пока что не выявил в чем могла быть проблема, возможно, как раз таки из за того, что нет стандартного файрвола в комплекте.

Для тестирования использовал VirtualBox 7.1.6, AlmaLinux 9.5 (minimal, без графической оболочки, psql 13.20), Debian 12.9.0 (образ netinst, c xfce, psql 15.10)
