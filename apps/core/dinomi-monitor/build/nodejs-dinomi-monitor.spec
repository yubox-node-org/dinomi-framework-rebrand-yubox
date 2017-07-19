%{?nodejs_find_provides_and_requires}

Name:       nodejs-dinomi-monitor
Version:    1.0.0
Release:    4%{?dist}
Summary:    DINOMI dashboard monitor for Node.js
License:    ISC
Group:      System Environment/Libraries
URL:        http://dinomi.com
Source0:    dinomi-monitor-%{version}-4.tgz
Requires:	nodejs
Requires:	nodejs-promise
Requires: 	nodejs-mysql
Requires:	nodejs-dinomi-eccp
Requires:	nodejs-supervisor
Requires:   httpd >= 2.4.6-32
Requires:	dinomi-system >= 1.0.0-2
Requires(post):	patch, grep
Prereq:		mod_ssl
BuildArch:  noarch

%description
DINOMI ISO dashboard monitor of local and remote services.

%prep
%setup -q -n dinomi-monitor
%nodejs_fixdep -r socket.io
%nodejs_fixdep -r node-json-db

%build
#nothing to do


%install
mkdir -p %{buildroot}/etc/httpd/conf.d/
mkdir -p %{buildroot}/usr/lib/systemd/system/

mv wstunnel-dashmon.conf		%{buildroot}/etc/httpd/conf.d/
mv dashmon.service 			%{buildroot}/usr/lib/systemd/system/

mkdir -p %{buildroot}%{nodejs_sitelib}/dinomi-monitor
cp -pr ssl.conf.patch package.json dashmon_index.js node_modules/ \
    %{buildroot}%{nodejs_sitelib}/dinomi-monitor

%nodejs_symlink_deps

%post
cd /etc/httpd/conf.d/
grep -R "RewriteCond %{REQUEST_URI}  ^/socket.io" . &> /dev/null
if [ $? = 0 ]; then
	echo "Nothing to do here."
else
	cd /etc/httpd/conf.d/
	patch -p4 < %{nodejs_sitelib}/dinomi-monitor/ssl.conf.patch
	rm -rf %{nodejs_sitelib}/dinomi-monitor/ssl.conf.patch
	systemctl enable dashmon.service
	service httpd restart
	systemctl start dashmon.service
fi

%files
# % doc LICENSE Readme.md
%{nodejs_sitelib}/dinomi-monitor
/usr/lib/systemd/system/dashmon.service
/etc/httpd/conf.d/wstunnel-dashmon.conf

%changelog
* Thu May 11 2017 Luis Anghelo Abarca Villacís <labarca@palosanto.com> - 1.0.0-4
- A better way to start the dashmon service has been deployed.

* Tue May 02 2017 Luis Anghelo Abarca Villacís <labarca@palosanto.com> - 1.0.0-3
- A way to handle errors to json db has been implemented.

* Tue May 02 2017 Luis Anghelo Abarca Villacís <labarca@palosanto.com> - 1.0.0-2
- Some bugs have been corrected.

* Tue Apr 18 2017 Luis Anghelo Abarca Villacís <labarca@palosanto.com> - 1.0.0-1
- Now once the ssl.conf.patch is applied its deleted.

* Mon Apr 10 2017 Luis Anghelo Abarca Villacís <labarca@palosanto.com> - 1.0.0-0
- initial package

