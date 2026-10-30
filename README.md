# Linux Lab Scripts

Колекція Bash-скриптів для лабораторних робіт
з курсу "Системне програмування та адміністрування ОС".

## Вміст

- `count_files.sh` - скрипт для підрахунку файлів у вказаному каталозі або, якщо параметр не передано, у каталозі /etc

## Використання

```bash
./count_files.sh [path/to/dir]
```

## RPM-пакет `count-files` (лабораторна №4)

Пакет встановлює скрипт як команду `count_files`, який рахує файли, директорії та символічні посилання у вказаній директорії (за замовчуванням `/etc`). Поточна версія: **2.0**.

### Вміст каталогу `rpm/`

- `count-files.spec` - spec-файл (версія 2.0, історія змін у `%changelog`)
- `count_files.1` - man-сторінка
- `count_files.conf` - конфігураційний файл
- `sources/` - tar-архіви вихідників (`count-files-1.0.tar.gz`, `count-files-2.0.tar.gz`)
- `packages/` - зібрані пакети (1.0 і 2.0, `.src.rpm`)
- `screenshots/` - скріншоти виконання

### Збірка

```bash
sudo dnf install rpm-build rpmdevtools
rpmdev-setuptree

mkdir -p ~/rpmbuild/SOURCES/count-files-2.0
cp count_files.sh rpm/count_files.1 rpm/count_files.conf ~/rpmbuild/SOURCES/count-files-2.0/
cd ~/rpmbuild/SOURCES
tar czvf count-files-2.0.tar.gz count-files-2.0

cp ~/projects/linux-lab-scripts/rpm/count-files.spec ~/rpmbuild/SPECS/
cd ~/rpmbuild/SPECS
rpmbuild -ba count-files.spec
```

### Перевірка пакета

```bash
rpm -qip ~/rpmbuild/RPMS/noarch/count-files-2.0-1*.rpm
rpm -qlp ~/rpmbuild/RPMS/noarch/count-files-2.0-1*.rpm
rpm -qp --scripts ~/rpmbuild/RPMS/noarch/count-files-2.0-1*.rpm
```

### Встановлення, оновлення, видалення

```bash
sudo rpm -ivh rpm/packages/count-files-1.0-1.noarch.rpm   # установка 1.0
sudo rpm -Uvh rpm/packages/count-files-2.0-1.noarch.rpm   # оновлення до 2.0
count_files            # підрахунок у /etc
count_files /var       # у вказаній директорії
man count_files
cat /var/log/count-files/install.log
sudo rpm -e count-files
```

### Що нового у версії 2.0

1. **Man-сторінка.** Додано `count_files.1`, яка встановлюється в `/usr/share/man/man1/` і доступна через `man count_files`.
2. **Конфігураційний файл.** Додано `/etc/count_files.conf`, позначений як `%config(noreplace)`: локальні зміни користувача не перезаписуються при оновленні пакета. Файл містить два параметри:
   - `TARGET_DIR` - директорія для підрахунку (за замовчуванням `/usr/share`);
   - `FILE_TYPE` - розширення файлів для окремого підрахунку (за замовчуванням `1`, тобто файли `*.1`, man-сторінки).
3. **Скрипти `%pre`, `%post`, `%postun`:**
   - `%pre`: виводить повідомлення про початок установки;
   - `%post`: створює каталог `/var/log/count-files`, записує дату установки в `install.log` і виводить підказку щодо запуску;
   - `%postun`: при повному видаленні пакета (`$1 -eq 0`) прибирає каталог `/var/log/count-files`, а при оновленні лог зберігається.
4. **Нові функції скрипта (версія 2.0):**
   - підрахунок файлів, директорій і символічних посилань;
   - параметр командного рядка для вибору директорії (якщо не передано, береться `TARGET_DIR` з конфігу, а за його відсутності `/etc`);
   - підрахунок файлів із певним розширенням (`FILE_TYPE` з конфігу);
   - читання налаштувань із `/etc/count_files.conf`.
5. **Оновлено метадані пакета:** `Version: 2.0`, `Release: 1`, додано запис у `%changelog`.

## DEB-пакет `count-files` (лабораторна №5)

Пакет встановлює скрипт як команду `count_files`, який рахує файли, директорії та символічні посилання у вказаній директорії (за замовчуванням `/etc`). Поточна версія: **2.0-1**.

### Вміст каталогу `deb/`

- `count-files-1.0/` — вихідні файли першої версії пакета;
- `count-files-2.0/` — вихідні файли другої версії пакета;
- `count-files-2.0-ppa/` — вихідні файли для публікації в Launchpad PPA;
- `releases/deb/` — зібрані DEB-пакети та супутні файли збірки;
- `releases/ppa/` — вихідні пакети для завантаження до Launchpad PPA.

### Збірка

```bash
sudo apt install build-essential devscripts debhelper dpkg-dev dh-make

cd deb/count-files-2.0
dpkg-buildpackage -us -uc -b
```

### Перевірка пакета

```bash
dpkg -I deb/releases/deb/count-files-2.0/count-files_2.0-1_all.deb
dpkg -c deb/releases/deb/count-files-2.0/count-files_2.0-1_all.deb
```

### Встановлення, оновлення, видалення

```bash
sudo apt install ./deb/releases/deb/count-files-2.0/count-files_2.0-1_all.deb
count_files                  # підрахунок у /etc
count_files /var             # у вказаній директорії
dpkg -s count-files          # інформація про пакет
dpkg -L count-files          # список встановлених файлів
sudo apt install --reinstall ./deb/releases/deb/count-files-2.0/count-files_2.0-1_all.deb
sudo apt remove count-files
sudo apt purge count-files
```

### Публікація в Launchpad PPA

```bash
cd deb/count-files-2.0-ppa
debuild -S -kYOUR_GPG_KEY
dput ppa ../count-files_2.0+ppa2_source.changes
```

PPA: https://launchpad.net/~johnnyrock2023/+archive/ubuntu/count-files

## Автор

Студент групи ПІ-242,
Куценко Роман Хакімович

