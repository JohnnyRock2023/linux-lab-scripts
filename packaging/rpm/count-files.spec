Name:           count-files
Version:        2.0
Release:        1%{?dist}
Summary:        Script to count files, directories and links in the specified directory or in /etc

License:        MIT
URL:            https://github.com/JohnnyRock2023/linux-lab-scripts
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       bash
Requires:       coreutils
Requires:       findutils

%description
A Bash script that counts the number of files, directories and links in the 
specified directory or, if the parameter is not passed, in the /etc directory

%pre
echo "Installing count-files, please wait..."

%post
mkdir -p /var/log/count-files
echo "count-files has been installed on $(date)" >> "/var/log/count-files/install.log"
echo "Run 'count_files' to count files."

%postun
if [ "$1" -eq 0 ]; then
   rm -rf "/var/log/count-files"
fi

%prep
%setup -q

%install
mkdir -p %{buildroot}%{_mandir}/man1
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_sysconfdir}
install -m 644 count_files.conf %{buildroot}%{_sysconfdir}/count_files.conf
install -m 644 count_files.1 %{buildroot}%{_mandir}/man1/count_files.1
install -m 755 count_files.sh %{buildroot}%{_bindir}/count_files

%files
%config(noreplace) %{_sysconfdir}/count_files.conf
%{_bindir}/count_files
%{_mandir}/man1/count_files.1*

%changelog
* Sun Oct 11 2026 Roman Kutsenko <kutsenkoroma147@gmail.com> - 2.0-1
- Added configuration file /etc/count_files.conf (%config(noreplace))
- Added man page count_files.1
- Added %pre, %post and %postun scriptlets (install log in /var/log/count-files)

* Sat Oct 10 2026 Roman Kutsenko <kutsenkoroma147@gmail.com> - 1.0-1
- Initial package release
