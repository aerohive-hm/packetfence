# A3 RPM SPEC
#
# NEW (since git migration):
#
#   Expecting a standard tarball with A3-<version>/...
#
# BUILDING FOR RELEASE
#
# - Build
#  - define ver <version>
#  - define dist based on target distro (for centos/rhel => .el5)
#  - define rev based on package revision (must be > 0 for proprer upgrade from snapshots)
# ex:
# cd /usr/src/redhat/
# rpmbuild -ba --define 'version 3.3.0' --define 'dist .el5' --define 'rev 1' SPECS/A3.spec
#
#
# BUILDING FOR A SNAPSHOT (PRE-RELEASE)
#
# - Build
#  - define ver <version>
#  - define snapshot 1
#  - define dist based on target distro (for centos/rhel => .el5)
#  - define rev to 0.<date> this way one can upgrade from snapshot to release
# ex:
# cd /usr/src/redhat/
# rpmbuild -ba --define 'version 3.3.0' --define 'snapshot 1' --define 'dist .el5' --define 'rev 0.20100506' SPECS/packetfence.spec
#
Summary: A3
%global real_name A3
%global perl_version 5.10.1
Name: %{real_name}-source
Version: %{ver}
Release: %{rev}%{?dist}
License: Proprietary
Group: System Environment/Daemons
URL: https://www.aerohive.com/
BuildRoot: %{_tmppath}/%{real_name}-%{version}-%{rev}-root
# disables the creation of the debug package for our setuid C wrapper
%define debug_package %{nil}

Packager: Kenshin Sakura <ksakura@aerohive.com>
Vendor: Aerohive Networks, Inc.  https://www.aerohive.com/

# if --define 'snapshot 1' not written when calling rpmbuild then we assume it is to package a release
%define is_release %{?snapshot:0}%{!?snapshot:1}
%if %{is_release}
# used for official releases
Source: http://10.16.134.140/src/%{real_name}-%{version}.tar.gz
%else
# used for snapshot releases
Source: http://10.16.134.140/src/%{real_name}-%{version}-%{rev}.tar.gz
%endif

# Log related globals
%global logfiles packetfence.log snmptrapd.log pfdetect pfmon
%global logdir /usr/local/pf/logs

BuildRequires: gettext, httpd, ipset-devel, pkgconfig
BuildRequires: perl(Parse::RecDescent)
# Required to build documentation
# See docs/docbook/README.asciidoc for more info about installing requirements.
# TODO fop on EL5 is actually xmlgraphics-fop
BuildRequires: asciidoc >= 8.6.2, fop, libxslt, docbook-style-xsl, xalan-j2

%description

A3 is a network access control (NAC) system. It can be used to effectively
secure networks, from small to very large heterogeneous networks. A3 provides
features such as:

* registration of new network devices
* detection of abnormal network activities
* isolation of problematic devices
* remediation through a captive portal
* registration-based and scheduled vulnerability scans.

# arch-specific pfcmd-suid subpackage required us to move all of PacketFence
# into a noarch subpackage and have the top level package virtual.

%package -n %{real_name}
Group: System Environment/Daemons
Summary: A3
BuildArch: noarch
# TODO we might consider re-enabling this to simplify our SPEC
AutoReqProv: 0

Requires: chkconfig, coreutils, grep, openssl, sed, tar, wget, gettext, conntrack-tools, patch
# for process management
Requires: procps
Requires: libpcap, libxml2, zlib, zlib-devel, glibc-common,
Requires: httpd, mod_ssl
Requires: mod_perl, mod_proxy_html
requires: libapreq2
Requires: redis
Requires: freeradius >= 3.0.15-4, freeradius-mysql, freeradius-perl, freeradius-ldap, freeradius-utils, freeradius-redis, freeradius-rest, freeradius-radsniff >= 3.0.15-4
Requires: make
Requires: net-tools
Requires: sscep
Requires: net-snmp >= 5.3.2.2
Requires: net-snmp-perl
Requires: perl >= %{perl_version}
Requires: MariaDB-server >= 10.1, MariaDB-client >= 10.1
Requires: perl(DBD::mysql)
# replaces the need for perl-suidperl which was deprecated in perl 5.12 (Fedora 14)
Requires(pre): %{real_name}-pfcmd-suid
Requires(pre): %{real_name}-ntlm-wrapper
Requires: perl(Bit::Vector)
Requires: perl(CGI::Session), perl(CGI::Session::Driver::chi) >= 1.0.3, perl(JSON) >= 2.90, perl(JSON::MaybeXS), perl(JSON::XS) >= 3
Requires: perl-Switch, perl-Locale-Codes
Requires: perl(Apache2::Request)
Requires: perl(Apache::Session)
Requires: perl(Class::Accessor)
Requires: perl(Class::Accessor::Fast::Contained)
Requires: perl(Class::Data::Inheritable)
Requires: perl(Class::Gomor)
Requires: perl(Config::IniFiles) >= 2.88
Requires: perl(Data::Phrasebook), perl(Data::Phrasebook::Loader::YAML)
Requires: perl(DBI)
Requires: perl(Rose::DB)
Requires: perl(Rose::DB::Object)
Requires: perl(Lingua::EN::Nums2Words) >= 1.16
Requires: perl(Lingua::EN::Inflexion) >= 0.001006
Requires: perl(Mojolicious)
Requires: perl(File::Tail)
Requires: perl(IPC::Cmd)
Requires: perl(IPTables::ChainMgr)
Requires: perl(IPTables::Parse)
Requires: perl(Tie::DxHash)
Requires: perl(File::FcntlLock)
requires: perl(Proc::ProcessTable)
requires: perl(Apache::SSLLookup)
requires: perl(Crypt::OpenSSL::PKCS12)
requires: perl(Crypt::OpenSSL::X509)
requires: perl(Crypt::OpenSSL::RSA)
requires: perl(Crypt::OpenSSL::PKCS10)
requires: perl(Const::Fast)
# Perl core modules but still explicitly defined just in case distro's core perl get stripped
Requires: perl(Time::HiRes)
# Required for inline mode.
Requires: ipset, sudo
Requires: perl(File::Which), perl(NetAddr::IP)
Requires: perl(Net::LDAP)
Requires: perl(Net::IP)
Requires: perl-libnet >= 3.10
Requires: perl(Socket) >= 2.016
Requires: perl(Digest::HMAC_MD5)
# TODO: we should depend on perl modules not perl-libwww-perl package
# find out what they are and specify them as perl(...::...) instead of perl-libwww-perl
# LWP::Simple is one of them (required by inlined Net::MAC::Vendor and probably other stuff)
Requires: perl-libwww-perl > 6.02, perl(LWP::Simple), perl(LWP::Protocol::https)
Requires: perl(List::MoreUtils)
Requires: perl-Scalar-List-Utils
Requires: perl(Locale::gettext)
Requires: perl(Log::Log4perl) >= 1.43
Requires: perl(MojoX::Log::Log4perl)
Requires: perl(Log::Any)
Requires: perl(Log::Any::Adapter)
Requires: perl(Log::Any::Adapter::Log4perl)
Requires: perl(Log::Dispatch::Syslog)
Requires: perl(Net::Cisco::MSE::REST)
# Required by switch modules
# Net::Appliance::Session specific version added because newer versions broke API compatibility (#1312)
# We would need to port to the new 3.x API (tracked by #1313)
Requires: perl(Net::Appliance::Session) = 1.36
Requires: perl(Net::SSH2) >= 0.63
Requires: perl(Net::OAuth2) >= 0.57
# Required by configurator script, pf::config
Requires: perl(Net::Interface)
Requires: perl(Net::Netmask)
# pfmon, pfdhcplistener
Requires: perl(Net::Pcap) >= 0.16
# pfdhcplistener
Requires: perl(NetPacket) >= 1.2.0
Requires: perl(Module::Metadata)
# systemd sd_notify support
Requires: perl(Systemd::Daemon)
# RADIUS CoA support
Requires: perl(Net::Radius::Dictionary), perl(Net::Radius::Packet)
# SNMP to network hardware
Requires: perl(Net::SNMP)
# for SNMPv3 AES as privacy protocol, fixes #775
Requires: perl(Crypt::Rijndael)
Requires: perl(Net::Telnet)
Requires: perl(Net::Write)
Requires: perl(Parse::RecDescent)
# for nessus scan, this version add the NBE download (inverse patch)
Requires: perl(Net::Nessus::XMLRPC) >= 0.40
Requires: perl(Net::Nessus::REST) >= 0.7
# Note: portability for non-x86 is questionnable for Readonly::XS
Requires: perl(Readonly), perl(Readonly::XS)
Requires: perl(Regexp::Common)
Requires: rrdtool, perl-rrdtool
Requires: perl(SOAP::Lite) >= 1.0
Requires: perl(WWW::Curl)
Requires: perl(Data::MessagePack)
Requires: perl(Data::MessagePack::Stream)
Requires: perl(POSIX::2008)
# Template::Toolkit - captive portal template system
Requires: perl(Template)
Requires: perl(Template::AutoFilter)
# Used by installer / configurator scripts
Requires: perl(Term::ReadKey)
Requires: perl(Thread::Pool)
Requires: perl(Date::Parse)
Requires: perl(DateTime::Format::RFC3339)
Requires: perl(UNIVERSAL::require)
Requires: perl(YAML)
Requires: perl(Try::Tiny)
Requires: perl(Crypt::GeneratePassword)
Requires: perl(Bytes::Random::Secure)
Requires: perl(Crypt::Eksblowfish::Bcrypt)
Requires: perl(Crypt::SmbHash)
Requires: perl(MIME::Lite::TT)
Requires: perl(Cache::Cache), perl(HTML::Parser)
Requires: perl(URI::Escape::XS)
# Used by Captive Portal authentication modules
Requires: perl(Apache::Htpasswd)
Requires: perl(Authen::Radius) >= 0.24
Requires: perl(Authen::Krb5::Simple)
Requires: perl(WWW::Twilio::API)
# Required for importation feature
Requires: perl(Text::CSV)
Requires: perl(Text::CSV_XS)
# BILLING ENGINE
Requires: perl(LWP::UserAgent)
Requires: perl(HTTP::Request::Common)
# Catalyst
Requires: perl(Catalyst::Runtime), perl(Catalyst::Plugin::ConfigLoader)
Requires: perl(Catalyst::Plugin::Static::Simple), perl(Catalyst::Action::RenderView)
Requires: perl(Config::General), perl(Catalyst::Plugin::StackTrace)
Requires: perl(Catalyst::Plugin::Session), perl(Catalyst::Plugin::Session::Store::File)
Requires: perl(Catalyst::Plugin::Session::State::Cookie)
Requires: perl(Catalyst::Plugin::I18N)
Requires: perl(Catalyst::View::TT) >= 0.42
Requires: perl(Catalyst::View::CSV)
Requires: perl(Catalyst::View::JSON), perl(Log::Log4perl::Catalyst)
Requires: perl(Catalyst::Plugin::Authentication)
Requires: perl(Catalyst::Authentication::Credential::HTTP)
Requires: perl(Catalyst::Authentication::Store::Htpasswd)
Requires: perl(Catalyst::Controller::HTML::FormFu)
Requires: perl(Params::Validate) >= 0.97
Requires: perl(Term::Size::Any)
Requires: perl(SQL::Abstract::More) >= 1.28
Requires: perl(SQL::Abstract::Plugin::InsertMulti) >= 0.04
Requires(pre): perl-aliased => 0.30
Requires(pre): perl-version
# for Catalyst stand-alone server
Requires: perl(Catalyst::Devel)
Requires: perl(Sort::Naturally)
Requires: perl(PHP::Serialization)
Requires: perl(File::Slurp)
# these are probably missing dependencies for the above.
# I shall file upstream tickets to openfusion before we integrate
Requires: perl(Plack), perl(Plack::Middleware::ReverseProxy)
Requires: perl(MooseX::Types::LoadableClass)
Requires: perl(Moose) <= 2.1005
Requires: perl(CHI) >= 0.59
Requires: perl(CHI::Memoize)
Requires: perl(Data::Serializer)
Requires: perl(Data::Structure::Util)
Requires: perl(Data::Swap)
Requires: perl(HTML::FormHandler) = 0.40019
Requires: perl(Redis::Fast)
Requires: perl(CHI::Driver::Redis)
Requires: perl(File::Flock)
Requires: perl(Perl::Version)
Requires: perl(Cache::FastMmap)
Requires: perl(Moo) >= 1.003000
Requires: perl(Term::ANSIColor)
Requires: perl(IO::Interactive)
Requires: perl(Net::ARP)
Requires: perl(Module::Loaded)
Requires: perl(Linux::FD)
Requires: perl(Linux::Inotify2)
Requires: perl(File::Touch)
Requires: perl(POSIX::AtFork)
Requires: perl(Hash::Merge)
Requires: perl(IO::Socket::INET6)
Requires: perl(IO::Socket::SSL) >= 2.049
Requires: perl(IO::Interface)
Requires: perl(Time::Period) >= 1.25
Requires: perl(Time::Piece)
Requires: perl(Number::Range)
Requires: perl(Algorithm::Combinatorics)
Requires: perl(Net::Syslog)
Requires: perl(Class::XSAccessor)
Requires: iproute >= 3.0.0, krb5-workstation
Requires: samba >= 4
Requires: perl(Linux::Distribution)
# configuration-wizard
Requires: vconfig
# wmi
Requires: wmi, perl(Net::WMIClient)
# SAML
Requires: lasso-perl
# Captive Portal Dynamic Routing
Requires: perl(Graph)
#Timezone
Requires: perl(DateTime::TimeZone)

Requires: samba-winbind-clients, samba-winbind
Requires: libdrm >= 2.4.74
Requires: netdata, fping

# pki
Requires: perl(Crypt::SMIME)


Requires: perl(Sereal::Encoder), perl(Sereal::Decoder), perl(Data::Serializer::Sereal) >= 1.04
#
# TESTING related
#
Requires: perl(Test::MockObject), perl(Test::MockModule)
Requires: perl(Test::Perl::Critic), perl(Test::WWW::Mechanize)
Requires: perl(Test::Pod), perl(Test::Pod::Coverage), perl(Test::Exception)
Requires: perl(Test::NoWarnings), perl(Test::ParallelSubtest)
# required for the fake CoA server
Requires: perl(Net::UDP)
# For managing the number of connections per device
%if %{is_release}
# used for official releases
Requires: %{real_name}-config = %{version}
Requires: %{real_name}-pfcmd-suid = %{version}
%else
# used for snapshot releases
Requires: %{real_name}-config = %{version}-%{rev}%{?dist}
Requires: %{real_name}-pfcmd-suid = %{version}-%{rev}%{?dist}
%endif
Requires: haproxy >= 1.6, keepalived >= 1.3.6
# CAUTION: we need to require the version we want for Fingerbank and ensure we don't want anything equal or above the next major release as it can add breaking changes
Requires: fingerbank >= 4.0.0, fingerbank < 5.0.0
Requires: perl(File::Tempdir)

# etcd
Requires: etcd >= 3.1

%description -n %{real_name}

A3 is a network access control (NAC) system. It can be used to effectively
secure networks, from small to very large heterogeneous networks. A3 provides
features such as:

* registration of new network devices
* detection of abnormal network activities
* isolation of problematic devices
* remediation through a captive portal
* registration-based and scheduled vulnerability scans.


%package -n %{real_name}-remote-arp-sensor
Group: System Environment/Daemons
Requires: perl >= %{perl_version}, perl(Config::IniFiles) >= 2.88, perl(IO::Socket::SSL), perl(XML::Parser), perl(Crypt::SSLeay), perl(LWP::Protocol::https), perl(Net::Pcap) >= 0.16, memcached, perl(Cache::Memcached)
Requires: perl(Moo), perl(Data::MessagePack), perl(WWW::Curl)
Conflicts: %{real_name}
AutoReqProv: 0
Summary: Files needed for sending MAC and IP addresses from ARP requests to A3
BuildArch: noarch

%description -n %{real_name}-remote-arp-sensor
The %{real_name}-remote-arp-sensor package contains the files needed
for sending MAC and IP from ARP requests to a A3 server.


%package -n %{real_name}-pfcmd-suid
Group: System Environment/Daemons
BuildRequires: gcc
AutoReqProv: 0
Summary: Replace pfcmd by a C wrapper for suid

%description -n %{real_name}-pfcmd-suid
The %{real_name}-pfcmd-suid is a C wrapper to replace perl-suidperl dependency.
See https://bugzilla.redhat.com/show_bug.cgi?id=611009

%package -n %{real_name}-ntlm-wrapper
Group: System Environment/Daemons
BuildRequires: gcc
AutoReqProv: 0
Summary: C wrapper for logging ntlm_auth latency.

%description -n %{real_name}-ntlm-wrapper
The %{real_name}-ntlm-wrapper is a C wrapper around the ntlm_auth utility to log authentication times and success/failures. It can either/both log to syslog and send metrics to a StatsD server.

%package -n %{real_name}-config
Group: System Environment/Daemons
Requires: perl(Cache::BDB)
Requires: perl(Log::Fast)
AutoReqProv: 0
Summary: Manage A3 Configuration
BuildArch: noarch

%description -n %{real_name}-config
The %{real_name}-config is a daemon that manage A3 configuration.


%prep
%setup -q -n %{real_name}-%{version}

%build

# generate translations
# TODO this is duplicated in debian/rules, we should aim to consolidate in a 'make' style step
for TRANSLATION in de en es fr he_IL it nl pl_PL pt_BR; do
    /usr/bin/msgfmt conf/locale/$TRANSLATION/LC_MESSAGES/packetfence.po \
      --output-file conf/locale/$TRANSLATION/LC_MESSAGES/packetfence.mo
done

%if %{builddoc} == 1
    # generating custom XSL for titlepage
    xsltproc -o docs/docbook/xsl/titlepage-fo.xsl \
        /usr/share/sgml/docbook/xsl-stylesheets/template/titlepage.xsl \
        docs/docbook/xsl/titlepage-fo.xml
    # admin, network device config, devel and ZEN install guides
    for GUIDE in $(ls docs/PacketFence*.asciidoc | xargs -n1 -I'{}' basename '{}' .asciidoc) ;do
    asciidoc -a docinfo2 -b docbook -d book \
        -o docs/docbook/$GUIDE.docbook \
        docs/$GUIDE.asciidoc
    xsltproc -o docs/docbook/$GUIDE.fo \
        docs/docbook/xsl/packetfence-fo.xsl \
        docs/docbook/$GUIDE.docbook
    fop -c docs/fonts/fop-config.xml \
        docs/docbook/$GUIDE.fo \
        -pdf docs/$GUIDE.pdf
    done
%endif

# Build the HTML doc for pfappserver
make html/pfappserver/root/static/doc

# build pfcmd C wrapper
gcc -g0 src/pfcmd.c -o bin/pfcmd
# build ntlm_auth_wrapper
make bin/ntlm_auth_wrapper
# Define git_commit_id
echo %{git_commit} > conf/git_commit_id

# build golang binaries
addons/packages/build-go.sh build `pwd` `pwd`/bin

find -name '*.example' -print0 | while read -d $'\0' file
do
  cp $file "$(dirname $file)/$(basename $file .example)"
done

%install
%{__rm} -rf $RPM_BUILD_ROOT
# systemd targets
%{__install} -D -m0644 conf/systemd/packetfence.target $RPM_BUILD_ROOT/etc/systemd/system/packetfence.target
%{__install} -D -m0644 conf/systemd/packetfence-base.target $RPM_BUILD_ROOT/etc/systemd/system/packetfence-base.target
%{__install} -D -m0644 conf/systemd/packetfence-cluster.target $RPM_BUILD_ROOT/etc/systemd/system/packetfence-cluster.target

%{__install} -d $RPM_BUILD_ROOT/etc/systemd/system/packetfence-base.target.wants
%{__install} -d $RPM_BUILD_ROOT/etc/systemd/system/packetfence.target.wants
%{__install} -d $RPM_BUILD_ROOT/etc/systemd/system/packetfence-cluster.target.wants
# systemd slices
%{__install} -D -m0644 conf/systemd/packetfence.slice $RPM_BUILD_ROOT/etc/systemd/system/packetfence.slice
%{__install} -D -m0644 conf/systemd/packetfence-base.slice $RPM_BUILD_ROOT/etc/systemd/system/packetfence-base.slice
# systemd services
%{__install} -D -m0644 conf/systemd/packetfence-api-frontend.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-api-frontend.service
%{__install} -D -m0644 conf/systemd/packetfence-config.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-config.service
%{__install} -D -m0644 conf/systemd/packetfence-haproxy.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-haproxy.service
%{__install} -D -m0644 conf/systemd/packetfence-httpd.aaa.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-httpd.aaa.service
%{__install} -D -m0644 conf/systemd/packetfence-httpd.admin.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-httpd.admin.service
%{__install} -D -m0644 conf/systemd/packetfence-httpd.collector.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-httpd.collector.service
%{__install} -D -m0644 conf/systemd/packetfence-httpd.parking.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-httpd.parking.service
%{__install} -D -m0644 conf/systemd/packetfence-httpd.portal.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-httpd.portal.service
%{__install} -D -m0644 conf/systemd/packetfence-httpd.proxy.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-httpd.proxy.service
%{__install} -D -m0644 conf/systemd/packetfence-httpd.webservices.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-httpd.webservices.service
%{__install} -D -m0644 conf/systemd/packetfence-iptables.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-iptables.service
%{__install} -D -m0644 conf/systemd/packetfence-pfunified_api.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfunified_api.service
%{__install} -D -m0644 conf/systemd/packetfence-keepalived.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-keepalived.service
%{__install} -D -m0644 conf/systemd/packetfence-mariadb.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-mariadb.service
%{__install} -D -m0644 conf/systemd/packetfence-pfbandwidthd.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfbandwidthd.service
%{__install} -D -m0644 conf/systemd/packetfence-pfdetect.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfdetect.service
%{__install} -D -m0644 conf/systemd/packetfence-pfdhcplistener.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfdhcplistener.service
%{__install} -D -m0644 conf/systemd/packetfence-pfdns.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfdns.service
%{__install} -D -m0644 conf/systemd/packetfence-pffilter.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pffilter.service
%{__install} -D -m0644 conf/systemd/packetfence-pfmon.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfmon.service
%{__install} -D -m0644 conf/systemd/packetfence-pfqueue.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfqueue.service
%{__install} -D -m0644 conf/systemd/packetfence-pfsetvlan.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfsetvlan.service
%{__install} -D -m0644 conf/systemd/packetfence-pfsso.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfsso.service
%{__install} -D -m0644 conf/systemd/packetfence-httpd.dispatcher.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-httpd.dispatcher.service
%{__install} -D -m0644 conf/systemd/packetfence-radiusd-acct.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-radiusd-acct.service
%{__install} -D -m0644 conf/systemd/packetfence-radiusd-auth.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-radiusd-auth.service
%{__install} -D -m0644 conf/systemd/packetfence-radiusd-cli.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-radiusd-cli.service
%{__install} -D -m0644 conf/systemd/packetfence-radiusd-eduroam.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-radiusd-eduroam.service
%{__install} -D -m0644 conf/systemd/packetfence-radiusd-load_balancer.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-radiusd-load_balancer.service
%{__install} -D -m0644 conf/systemd/packetfence-radsniff.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-radsniff.service
%{__install} -D -m0644 conf/systemd/packetfence-redis-cache.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-redis-cache.service
%{__install} -D -m0644 conf/systemd/packetfence-redis_ntlm_cache.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-redis_ntlm_cache.service
%{__install} -D -m0644 conf/systemd/packetfence-redis_queue.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-redis_queue.service
%{__install} -D -m0644 conf/systemd/packetfence-routes.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-routes.service
%{__install} -D -m0644 conf/systemd/packetfence-snmptrapd.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-snmptrapd.service
%{__install} -D -m0644 conf/systemd/packetfence-tc.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-tc.service
%{__install} -D -m0644 conf/systemd/packetfence-winbindd.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-winbindd.service
%{__install} -D -m0644 conf/systemd/packetfence-etcd.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-etcd.service
%{__install} -D -m0644 conf/systemd/packetfence-pfdhcp.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfdhcp.service
%{__install} -D -m0644 conf/systemd/packetfence-pfipset.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfipset.service
%{__install} -D -m0644 conf/systemd/packetfence-netdata.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-netdata.service
%{__install} -D -m0644 conf/systemd/packetfence-pfstats.service $RPM_BUILD_ROOT/usr/lib/systemd/system/packetfence-pfstats.service

%{__install} -d $RPM_BUILD_ROOT/usr/local/pf/addons
%{__install} -d $RPM_BUILD_ROOT/usr/local/pf/addons/AD
%{__install} -d -m2770 $RPM_BUILD_ROOT/usr/local/pf/conf
%{__install} -d $RPM_BUILD_ROOT/usr/local/pf/conf/radiusd
%{__install} -d $RPM_BUILD_ROOT/usr/local/pf/conf/ssl
%{__install} -d -m2775 $RPM_BUILD_ROOT%logdir
%{__install} -d $RPM_BUILD_ROOT/usr/local/pf/raddb/sites-enabled
%{__install} -d -m2775 $RPM_BUILD_ROOT/usr/local/pf/var
%{__install} -d -m2775 $RPM_BUILD_ROOT/usr/local/pf/var/cache
%{__install} -d -m2775 $RPM_BUILD_ROOT/usr/local/pf/var/cache/ntlm_cache_users
%{__install} -d -m2775 $RPM_BUILD_ROOT/usr/local/pf/var/redis_cache
%{__install} -d -m2775 $RPM_BUILD_ROOT/usr/local/pf/var/redis_queue
%{__install} -d -m2775 $RPM_BUILD_ROOT/usr/local/pf/var/redis_ntlm_cache
%{__install} -d -m2775 $RPM_BUILD_ROOT/usr/local/pf/var/ssl_mutex
%{__install} -d $RPM_BUILD_ROOT/usr/local/pf/var/conf
%{__install} -d -m2775 $RPM_BUILD_ROOT/usr/local/pf/var/run
%{__install} -d $RPM_BUILD_ROOT/usr/local/pf/var/rrd
%{__install} -d $RPM_BUILD_ROOT/usr/local/pf/var/session
%{__install} -d $RPM_BUILD_ROOT/usr/local/pf/var/webadmin_cache
%{__install} -d $RPM_BUILD_ROOT/usr/local/pf/var/control
%{__install} -d $RPM_BUILD_ROOT/etc/sudoers.d
%{__install} -d $RPM_BUILD_ROOT/etc/cron.d
touch $RPM_BUILD_ROOT/usr/local/pf/var/cache_control
cp Makefile $RPM_BUILD_ROOT/usr/local/pf/
cp -r bin $RPM_BUILD_ROOT/usr/local/pf/
cp -r addons/pfconfig/ $RPM_BUILD_ROOT/usr/local/pf/addons/
cp -r addons/captive-portal/ $RPM_BUILD_ROOT/usr/local/pf/addons/
cp -r addons/dev-helpers/ $RPM_BUILD_ROOT/usr/local/pf/addons/
cp -r addons/high-availability/ $RPM_BUILD_ROOT/usr/local/pf/addons/
cp -r addons/integration-testing/ $RPM_BUILD_ROOT/usr/local/pf/addons/
cp -r addons/packages/ $RPM_BUILD_ROOT/usr/local/pf/addons/
cp -r addons/upgrade/ $RPM_BUILD_ROOT/usr/local/pf/addons/
cp -r addons/watchdog/ $RPM_BUILD_ROOT/usr/local/pf/addons/
cp -r addons/AD/* $RPM_BUILD_ROOT/usr/local/pf/addons/AD/
cp -r addons/monit/ $RPM_BUILD_ROOT/usr/local/pf/addons/
cp addons/*.pl $RPM_BUILD_ROOT/usr/local/pf/addons/
cp addons/*.sh $RPM_BUILD_ROOT/usr/local/pf/addons/
%{__install} -D packetfence.logrotate $RPM_BUILD_ROOT/etc/logrotate.d/packetfence
%{__install} -D packetfence.rsyslog-drop-in.service $RPM_BUILD_ROOT/etc/systemd/system/rsyslog.service.d/packetfence.conf
%{__install} -D packetfence.journald $RPM_BUILD_ROOT/usr/lib/systemd/journald.conf.d/01-packetfence.conf
cp -r sbin $RPM_BUILD_ROOT/usr/local/pf/
cp -r conf $RPM_BUILD_ROOT/usr/local/pf/
mv -f $RPM_BUILD_ROOT/usr/local/pf/conf/a3-release $RPM_BUILD_ROOT/usr/local/pf/conf/pf-release
cp -r raddb $RPM_BUILD_ROOT/usr/local/pf/
mv packetfence.sudoers $RPM_BUILD_ROOT/etc/sudoers.d/packetfence
mv packetfence.cron.d $RPM_BUILD_ROOT/etc/cron.d/packetfence
mv addons/pfarp_remote/sbin/pfarp_remote $RPM_BUILD_ROOT/usr/local/pf/sbin
mv addons/pfarp_remote/conf/pfarp_remote.conf $RPM_BUILD_ROOT/usr/local/pf/conf
rmdir addons/pfarp_remote/sbin
rm addons/pfarp_remote/initrd/pfarp
rmdir addons/pfarp_remote/initrd
rmdir addons/pfarp_remote/conf
rmdir addons/pfarp_remote
cp -r ChangeLog $RPM_BUILD_ROOT/usr/local/pf/
cp -r COPYING $RPM_BUILD_ROOT/usr/local/pf/
cp -r db $RPM_BUILD_ROOT/usr/local/pf/
cp -r docs $RPM_BUILD_ROOT/usr/local/pf/
rm -rf $RPM_BUILD_ROOT/usr/local/pf/docs/archives
rm -rf $RPM_BUILD_ROOT/usr/local/pf/docs/docbook
rm -rf $RPM_BUILD_ROOT/usr/local/pf/docs/fonts
rm -rf $RPM_BUILD_ROOT/usr/local/pf/docs/images
rm -rf $RPM_BUILD_ROOT/usr/local/pf/docs/api
cp -r html $RPM_BUILD_ROOT/usr/local/pf/
cp -r lib $RPM_BUILD_ROOT/usr/local/pf/
cp -r go $RPM_BUILD_ROOT/usr/local/pf/
cp -r NEWS.asciidoc $RPM_BUILD_ROOT/usr/local/pf/
cp -r NEWS.old $RPM_BUILD_ROOT/usr/local/pf/
cp -r README.md $RPM_BUILD_ROOT/usr/local/pf/
cp -r README.network-devices $RPM_BUILD_ROOT/usr/local/pf/
cp -r UPGRADE.asciidoc $RPM_BUILD_ROOT/usr/local/pf/
cp -r UPGRADE.old $RPM_BUILD_ROOT/usr/local/pf/
# logfiles
for LOG in %logfiles; do
    touch $RPM_BUILD_ROOT%logdir/$LOG
done
#start create symlinks
curdir=`pwd`

#pf-schema.sql symlinks to current schema
if [ ! -h "$RPM_BUILD_ROOT/usr/local/pf/db/pf-schema.sql" ]; then
    cd $RPM_BUILD_ROOT/usr/local/pf/db
    VERSIONSQL=$(ls pf-schema-* |sort -r | head -1)
    ln -f -s $VERSIONSQL ./pf-schema.sql
fi

#radius sites-enabled symlinks
#We standardize the way to use site-available/sites-enabled for the RADIUS server
cd $RPM_BUILD_ROOT/usr/local/pf/raddb/sites-enabled
ln -s ../sites-available/dynamic-clients dynamic-clients
ln -s ../sites-available/status status

# Fingerbank symlinks
cd $RPM_BUILD_ROOT/usr/local/pf/lib
ln -s /usr/local/fingerbank/lib/fingerbank fingerbank

cd $curdir
#end create symlinks

%clean
rm -rf $RPM_BUILD_ROOT

%pre -n %{real_name}

/usr/bin/systemctl --now mask mariadb
# clean up the old systemd files if it's an upgrade
if [ "$1" = "2"   ]; then
    /usr/bin/systemctl disable packetfence-redis-cache
    /usr/bin/systemctl disable packetfence-config
    /usr/bin/systemctl disable packetfence.service
fi

if ! /usr/bin/id pf &>/dev/null; then
    if ! /bin/getent group  pf &>/dev/null; then
        /usr/sbin/useradd -r -d "/usr/local/pf" -s /bin/sh -c "PacketFence" -M pf || \
                echo Unexpected error adding user "pf" && exit
    else
        /usr/sbin/useradd -r -d "/usr/local/pf" -s /bin/sh -c "PacketFence" -M pf -g pf || \
                echo Unexpected error adding user "pf" && exit
    fi
fi
/usr/sbin/usermod -aG wbpriv,fingerbank,apache pf
/usr/sbin/usermod -aG pf mysql
/usr/sbin/usermod -aG pf netdata

if [ ! `id -u` = "0" ];
then
  echo You must install this package as root!
  exit
fi

%pre -n %{real_name}-remote-arp-sensor

if ! /usr/bin/id pf &>/dev/null; then
    if ! /bin/getent group  pf &>/dev/null; then
        /usr/sbin/useradd -r -d "/usr/local/pf" -s /bin/sh -c "PacketFence" -M pf || \
                echo Unexpected error adding user "pf" && exit
    else
        /usr/sbin/useradd -r -d "/usr/local/pf" -s /bin/sh -c "PacketFence" -M pf -g pf || \
                echo Unexpected error adding user "pf" && exit
    fi
fi

%pre -n %{real_name}-config

if ! /usr/bin/id pf &>/dev/null; then
    if ! /bin/getent group  pf &>/dev/null; then
        /usr/sbin/useradd -r -d "/usr/local/pf" -s /bin/sh -c "PacketFence" -M pf || \
                echo Unexpected error adding user "pf" && exit
    else
        /usr/sbin/useradd -r -d "/usr/local/pf" -s /bin/sh -c "PacketFence" -M pf -g pf || \
                echo Unexpected error adding user "pf" && exit
    fi
fi


%post -n %{real_name}

/usr/bin/mkdir -p /var/log/journal/
echo "Restarting journald to enable persistent logging"
/bin/systemctl restart systemd-journald

if [ `systemctl get-default` = "packetfence-cluster.target" ]; then
    echo "This is an upgrade on a clustered system. We don't change the default systemd target."
else
    echo "Setting packetfence.target as the default systemd target."
    /bin/systemctl set-default packetfence.target
fi

#Check if log files exist and create them with the correct owner
for fic_log in packetfence.log redis_cache.log
do
if [ ! -e /usr/local/pf/logs/$fic_log ]; then
  touch /usr/local/pf/logs/$fic_log
  chown pf.pf /usr/local/pf/logs/$fic_log
  chmod g+w /usr/local/pf/logs/$fic_log
fi
done

echo "Restarting rsyslogd"
/bin/systemctl restart rsyslog

#Make ssl certificate
cd /usr/local/pf
make conf/ssl/server.pem

# Create server local RADIUS secret
if [ ! -f /usr/local/pf/conf/local_secret ]; then
    date +%s | sha256sum | base64 | head -c 32 > /usr/local/pf/conf/local_secret
fi

for service in httpd snmptrapd portreserve redis
do
  if /bin/systemctl -a | grep $service > /dev/null 2>&1; then
    echo "Disabling $service startup script"
    /bin/systemctl disable $service > /dev/null 2>&1
  fi
done

#Check if RADIUS have a dh
if [ ! -f /usr/local/pf/raddb/certs/dh ]; then
  echo "Building default RADIUS certificates..."
  cd /usr/local/pf/raddb/certs
  make
else
  echo "DH already exists, won't touch it!"
fi

if [ ! -f /usr/local/pf/conf/pf.conf ]; then
  echo "Touch pf.conf because it doesnt exist"
  touch /usr/local/pf/conf/pf.conf
  chown pf.pf /usr/local/pf/conf/pf.conf
else
  echo "pf.conf already exists, won't touch it!"
fi

#Getting rid of SELinux
echo "Disabling SELinux..."
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

# Getting rid of wrong ipv6 dns address
sed -i 's/\%.*$//g' /etc/resolv.conf

# Enabling ip forwarding
echo "# ip forwarding enabled by A3" > /etc/sysctl.d/99-ip_forward.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/99-ip_forward.conf
sysctl -p /etc/sysctl.d/99-ip_forward.conf

# reloading systemd unit files
/bin/systemctl daemon-reload

#Starting PacketFence.
echo "Starting A3 Administration GUI..."
#removing old cache
rm -rf /usr/local/pf/var/cache/
/usr/bin/firewall-cmd --zone=public --add-port=1443/tcp
/bin/systemctl disable firewalld
/bin/systemctl enable packetfence-mariadb
/bin/systemctl enable packetfence-redis-cache
/bin/systemctl enable packetfence-config
/bin/systemctl disable packetfence-iptables
/bin/systemctl enable packetfence-routes
/bin/systemctl isolate packetfence-base
/bin/systemctl enable packetfence-httpd.admin
/bin/systemctl enable packetfence-iptables

/usr/local/pf/bin/pfcmd configreload
/bin/systemctl start packetfence-httpd.admin



echo Installation complete
echo "  * Please fire up your Web browser and go to https://@ip_packetfence:1443/configurator to complete your A3 configuration."
echo "  * Please stop your iptables service if you don't have access to configurator."

%post -n %{real_name}-remote-arp-sensor
echo "Adding A3 remote ARP Sensor startup script"
/sbin/chkconfig --add pfarp

%post -n %{real_name}-config
chown pf.pf /usr/local/pf/conf/pfconfig.conf
echo "Adding A3 config startup script"
/bin/systemctl enable packetfence-config

%preun -n %{real_name}
if [ $1 -eq 0 ] ; then
/bin/systemctl set-default multi-user.target
/bin/systemctl isolate multi-user.target
fi

%preun -n %{real_name}-remote-arp-sensor
if [ $1 -eq 0 ] ; then
        /sbin/service pfarp stop &>/dev/null || :
        /sbin/chkconfig --del pfarp
fi

%preun -n %{real_name}-config
if [ $1 -eq 0 ] ; then
/bin/systemctl stop packetfence-config
/bin/systemctl disable packetfence-config
fi

%postun -n %{real_name}
if [ $1 -eq 0 ]; then
        if /usr/bin/id pf &>/dev/null; then
               /usr/sbin/userdel pf || %logmsg "User \"pf\" could not be deleted."
        fi
fi

%postun -n %{real_name}-remote-arp-sensor
if [ $1 -eq 0 ]; then
        if /usr/bin/id pf &>/dev/null; then
                /usr/sbin/userdel pf || %logmsg "User \"pf\" could not be deleted."
        fi
fi

%postun -n %{real_name}-config
if [ $1 -eq 0 ]; then
        if /usr/bin/id pf &>/dev/null; then
                /usr/sbin/userdel pf || %logmsg "User \"pf\" could not be deleted."
        fi
fi

# TODO we should simplify this file manifest to the maximum keeping treating
# only special attributes explicitly
# "To make this situation a bit easier, if the %files list contains a path
# to a directory, RPM will automatically package every file in that
# directory, as well as every file in each subdirectory."
# -- http://www.rpm.org/max-rpm/s1-rpm-inside-files-list.html
%files -n %{real_name}

%defattr(-, pf, pf)
%attr(0644, root, root) /etc/systemd/system/packetfence.target
%attr(0644, root, root) /etc/systemd/system/packetfence-base.target
%attr(0644, root, root) /etc/systemd/system/packetfence-cluster.target
%attr(0644, root, root) /etc/systemd/system/packetfence*.slice

%exclude                /usr/lib/systemd/system/packetfence-config.service
%attr(0644, root, root) /usr/lib/systemd/system/packetfence-*.service
%attr(0644, root, root) /usr/lib/systemd/journald.conf.d/01-packetfence.conf

%dir %attr(0750, root,root) /etc/systemd/system/packetfence*target.wants
%attr(0644, root, root) /etc/systemd/system/rsyslog.service.d/packetfence.conf

%dir %attr(0750,root,root) %{_sysconfdir}/sudoers.d
%config %attr(0440,root,root) %{_sysconfdir}/sudoers.d/packetfence
%config %attr(0644,root,root) %{_sysconfdir}/logrotate.d/packetfence
%config %attr(0600,root,root) %{_sysconfdir}/cron.d/packetfence

%dir                    /usr/local/pf
                        /usr/local/pf/Makefile
%dir                    /usr/local/pf/addons
%attr(0755, pf, pf)     /usr/local/pf/addons/*.pl
%attr(0755, pf, pf)     /usr/local/pf/addons/*.sh
%dir                    /usr/local/pf/addons/AD/
                        /usr/local/pf/addons/AD/*
%dir                    /usr/local/pf/addons/captive-portal/
                        /usr/local/pf/addons/captive-portal/*
%dir                    /usr/local/pf/addons/dev-helpers/
                        /usr/local/pf/addons/dev-helpers/*
%dir                    /usr/local/pf/addons/high-availability/
                        /usr/local/pf/addons/high-availability/*
%dir                    /usr/local/pf/addons/integration-testing/
                        /usr/local/pf/addons/integration-testing/*
%dir                    /usr/local/pf/addons/monit
                        /usr/local/pf/addons/monit/*
%dir                    /usr/local/pf/addons/packages
                        /usr/local/pf/addons/packages/*
%dir                    /usr/local/pf/addons/pfconfig
%dir                    /usr/local/pf/addons/pfconfig/comparator
%attr(0755, pf, pf)     /usr/local/pf/addons/pfconfig/comparator/*.pl
%attr(0755, pf, pf)     /usr/local/pf/addons/pfconfig/comparator/*.sh
%dir                    /usr/local/pf/addons/upgrade
%attr(0755, pf, pf)     /usr/local/pf/addons/upgrade/*.pl
%dir                    /usr/local/pf/addons/watchdog
%attr(0755, pf, pf)     /usr/local/pf/addons/watchdog/*.sh
%dir                    /usr/local/pf/bin
%attr(0755, pf, pf)     /usr/local/pf/bin/pfhttpd
%attr(0755, pf, pf)     /usr/local/pf/bin/pfcmd.pl
%attr(0755, pf, pf)     /usr/local/pf/bin/pfcmd_vlan
%attr(0755, pf, pf)     /usr/local/pf/bin/pftest
                        /usr/local/pf/bin/pflogger-packetfence
%attr(0755, pf, pf)     /usr/local/pf/bin/pflogger.pl
%attr(0755, pf, pf)     /usr/local/pf/bin/cluster/maintenance
%attr(0755, pf, pf)     /usr/local/pf/bin/cluster/management_update
%attr(0755, pf, pf)     /usr/local/pf/bin/cluster/sync
%attr(0755, pf, pf)     /usr/local/pf/bin/cluster/pfupdate
%attr(0755, pf, pf)     /usr/local/pf/bin/cluster/maintenance
%attr(0755, pf, pf)     /usr/local/pf/bin/cluster/node
%attr(0755, pf, pf)     /usr/local/pf/bin/pfdhcp
%attr(0755, pf, pf)     /usr/local/pf/bin/pfdns
%attr(0755, pf, pf)     /usr/local/pf/bin/pfstats
%doc                    /usr/local/pf/ChangeLog
                        /usr/local/pf/conf/*.example
%config(noreplace)      /usr/local/pf/conf/adminroles.conf
%config(noreplace)      /usr/local/pf/conf/allowed_device_oui.txt
                        /usr/local/pf/conf/allowed_device_oui.txt.example
%config(noreplace)      /usr/local/pf/conf/apache_filters.conf
                        /usr/local/pf/conf/apache_filters.conf.example
%config(noreplace)      /usr/local/pf/conf/authentication.conf
%config                 /usr/local/pf/conf/caddy-services/*.conf
                        /usr/local/pf/conf/caddy-services/*.conf.example
%config(noreplace)      /usr/local/pf/conf/chi.conf
%config                 /usr/local/pf/conf/chi.conf.defaults
%config(noreplace)      /usr/local/pf/conf/pfdns.conf
%config(noreplace)      /usr/local/pf/conf/portal_modules.conf
%config                 /usr/local/pf/conf/portal_modules.conf.defaults
%config(noreplace)      /usr/local/pf/conf/device_registration.conf
%config                 /usr/local/pf/conf/device_registration.conf.defaults
                        /usr/local/pf/conf/device_registration.conf.example
%config                 /usr/local/pf/conf/dhcp_fingerprints.conf
%config(noreplace)      /usr/local/pf/conf/dhcp_filters.conf
                        /usr/local/pf/conf/dhcp_filters.conf.example
%config(noreplace)      /usr/local/pf/conf/dns_filters.conf
                        /usr/local/pf/conf/dns_filters.conf.example
%config                 /usr/local/pf/conf/dns_filters.conf.defaults
%config                 /usr/local/pf/conf/documentation.conf
%config(noreplace)      /usr/local/pf/conf/etcd.conf.yml
                        /usr/local/pf/conf/etcd.conf.yml.example
%config(noreplace)      /usr/local/pf/conf/firewall_sso.conf
                        /usr/local/pf/conf/firewall_sso.conf.example
%config(noreplace)      /usr/local/pf/conf/survey.conf
%config                 /usr/local/pf/conf/survey.conf.example
%config(noreplace)      /usr/local/pf/conf/redis_cache.conf
                        /usr/local/pf/conf/redis_cache.conf.example
%config(noreplace)      /usr/local/pf/conf/redis_queue.conf
                        /usr/local/pf/conf/redis_queue.conf.example
%config(noreplace)      /usr/local/pf/conf/redis_ntlm_cache.conf
                        /usr/local/pf/conf/redis_ntlm_cache.conf.example
%config(noreplace)      /usr/local/pf/conf/stats.conf
                        /usr/local/pf/conf/stats.conf.example
%config(noreplace)      /usr/local/pf/conf/floating_network_device.conf
%config(noreplace)      /usr/local/pf/conf/guest-managers.conf
                        /usr/local/pf/conf/git_commit_id
                        /usr/local/pf/conf/saml-sp-metadata.xml
%dir                    /usr/local/pf/conf/locale
%dir                    /usr/local/pf/conf/locale/de
%dir                    /usr/local/pf/conf/locale/de/LC_MESSAGES
%config(noreplace)      /usr/local/pf/conf/locale/de/LC_MESSAGES/packetfence.po
%config(noreplace)      /usr/local/pf/conf/locale/de/LC_MESSAGES/packetfence.mo
%dir                    /usr/local/pf/conf/locale/en
%dir                    /usr/local/pf/conf/locale/en/LC_MESSAGES
%config(noreplace)      /usr/local/pf/conf/locale/en/LC_MESSAGES/packetfence.po
%config(noreplace)      /usr/local/pf/conf/locale/en/LC_MESSAGES/packetfence.mo
%dir                    /usr/local/pf/conf/locale/es
%dir                    /usr/local/pf/conf/locale/es/LC_MESSAGES
%config(noreplace)      /usr/local/pf/conf/locale/es/LC_MESSAGES/packetfence.po
%config(noreplace)      /usr/local/pf/conf/locale/es/LC_MESSAGES/packetfence.mo
%dir                    /usr/local/pf/conf/locale/fr
%dir                    /usr/local/pf/conf/locale/fr/LC_MESSAGES
%config(noreplace)      /usr/local/pf/conf/locale/fr/LC_MESSAGES/packetfence.po
%config(noreplace)      /usr/local/pf/conf/locale/fr/LC_MESSAGES/packetfence.mo
%dir                    /usr/local/pf/conf/locale/he_IL
%dir                    /usr/local/pf/conf/locale/he_IL/LC_MESSAGES
%config(noreplace)      /usr/local/pf/conf/locale/he_IL/LC_MESSAGES/packetfence.po
%config(noreplace)      /usr/local/pf/conf/locale/he_IL/LC_MESSAGES/packetfence.mo
%dir                    /usr/local/pf/conf/locale/it
%dir                    /usr/local/pf/conf/locale/it/LC_MESSAGES
%config(noreplace)      /usr/local/pf/conf/locale/it/LC_MESSAGES/packetfence.po
%config(noreplace)      /usr/local/pf/conf/locale/it/LC_MESSAGES/packetfence.mo
%dir                    /usr/local/pf/conf/locale/nl
%dir                    /usr/local/pf/conf/locale/nl/LC_MESSAGES
%config(noreplace)      /usr/local/pf/conf/locale/nl/LC_MESSAGES/packetfence.po
%config(noreplace)      /usr/local/pf/conf/locale/nl/LC_MESSAGES/packetfence.mo
%dir                    /usr/local/pf/conf/locale/pl_PL
%dir                    /usr/local/pf/conf/locale/pl_PL/LC_MESSAGES
%config(noreplace)      /usr/local/pf/conf/locale/pl_PL/LC_MESSAGES/packetfence.po
%config(noreplace)      /usr/local/pf/conf/locale/pl_PL/LC_MESSAGES/packetfence.mo
%dir                    /usr/local/pf/conf/locale/pt_BR
%dir                    /usr/local/pf/conf/locale/pt_BR/LC_MESSAGES
%config(noreplace)      /usr/local/pf/conf/locale/pt_BR/LC_MESSAGES/packetfence.po
%config(noreplace)      /usr/local/pf/conf/locale/pt_BR/LC_MESSAGES/packetfence.mo
%config(noreplace)      /usr/local/pf/conf/log.conf
%dir                    /usr/local/pf/conf/log.conf.d
%config(noreplace)      /usr/local/pf/conf/log.conf.d/*.conf
                        /usr/local/pf/conf/log.conf.d/*.example
%dir                    /usr/local/pf/conf/mariadb
%config                 /usr/local/pf/conf/mariadb/*.tt
                        /usr/local/pf/conf/mariadb/*.tt.example
%dir                    /usr/local/pf/conf/nessus
%config(noreplace)      /usr/local/pf/conf/nessus/remotescan.nessus
                        /usr/local/pf/conf/nessus/remotescan.nessus.example
%config(noreplace)      /usr/local/pf/conf/networks.conf
%config                 /usr/local/pf/conf/openssl.cnf
%config                 /usr/local/pf/conf/oui.txt
%config                 /usr/local/pf/conf/passthrough.lua.tt
%config                 /usr/local/pf/conf/pf.conf.defaults
                        /usr/local/pf/conf/pf-release
%config(noreplace)      /usr/local/pf/conf/pki_provider.conf
                        /usr/local/pf/conf/pki_provider.conf.example
%config(noreplace)      /usr/local/pf/conf/provisioning.conf
                        /usr/local/pf/conf/provisioning.conf.example
%config(noreplace)      /usr/local/pf/conf/radius_filters.conf
                        /usr/local/pf/conf/radius_filters.conf.example
%dir			/usr/local/pf/conf/radiusd
%config(noreplace)      /usr/local/pf/conf/radiusd/clients.conf.inc
                        /usr/local/pf/conf/radiusd/clients.conf.inc.example
%config(noreplace)      /usr/local/pf/conf/radiusd/packetfence-cluster
                        /usr/local/pf/conf/radiusd/packetfence-cluster.example
%config(noreplace)      /usr/local/pf/conf/radiusd/proxy.conf.inc
                        /usr/local/pf/conf/radiusd/proxy.conf.inc.example
%config(noreplace)      /usr/local/pf/conf/radiusd/proxy.conf.loadbalancer
                        /usr/local/pf/conf/radiusd/proxy.conf.loadbalancer.example
%config(noreplace)	/usr/local/pf/conf/radiusd/eap.conf
                        /usr/local/pf/conf/radiusd/eap.conf.example
%config(noreplace)	/usr/local/pf/conf/radiusd/radiusd.conf
                        /usr/local/pf/conf/radiusd/radiusd.conf.example
%config(noreplace)	/usr/local/pf/conf/radiusd/sql.conf
                        /usr/local/pf/conf/radiusd/sql.conf.example
%config(noreplace)	/usr/local/pf/conf/radiusd/packetfence
                        /usr/local/pf/conf/radiusd/packetfence.example
%config(noreplace)	/usr/local/pf/conf/radiusd/packetfence-tunnel
                        /usr/local/pf/conf/radiusd/packetfence-tunnel.example
%config(noreplace)      /usr/local/pf/conf/radiusd/acct.conf
                        /usr/local/pf/conf/radiusd/acct.conf.example
%config(noreplace)      /usr/local/pf/conf/radiusd/auth.conf
                        /usr/local/pf/conf/radiusd/auth.conf.example
%config(noreplace)      /usr/local/pf/conf/radiusd/load_balancer.conf
                        /usr/local/pf/conf/radiusd/load_balancer.conf.example
%config(noreplace)      /usr/local/pf/conf/radiusd/rest.conf
                        /usr/local/pf/conf/radiusd/rest.conf.example
%config(noreplace)      /usr/local/pf/conf/radiusd/cli.conf
                        /usr/local/pf/conf/radiusd/cli.conf.example
%config(noreplace)      /usr/local/pf/conf/radiusd/packetfence-cli
                        /usr/local/pf/conf/radiusd/packetfence-cli.example
%config(noreplace)      /usr/local/pf/conf/radiusd/eduroam
                        /usr/local/pf/conf/radiusd/eduroam.example
%config(noreplace)      /usr/local/pf/conf/radiusd/eduroam-cluster
                        /usr/local/pf/conf/radiusd/eduroam-cluster.example
%config(noreplace)      /usr/local/pf/conf/radiusd/eduroam.conf
                        /usr/local/pf/conf/radiusd/eduroam.conf.example
%config(noreplace)      /usr/local/pf/conf/radiusd/radiusd_loadbalancer.conf
                        /usr/local/pf/conf/radiusd/radiusd_loadbalancer.conf.example
%config(noreplace)      /usr/local/pf/conf/realm.conf
                        /usr/local/pf/conf/realm.conf.example
%config                 /usr/local/pf/conf/realm.conf.defaults
%config(noreplace)      /usr/local/pf/conf/radius_filters.conf
                        /usr/local/pf/conf/radius_filters.conf.example
%config(noreplace)      /usr/local/pf/conf/rsyslog.conf.tt
%config(noreplace)      /usr/local/pf/conf/billing_tiers.conf
                        /usr/local/pf/conf/billing_tiers.conf.example
%config(noreplace)      /usr/local/pf/conf/domain.conf
                        /usr/local/pf/conf/domain.conf.example
%config(noreplace)      /usr/local/pf/conf/pfdetect.conf
                        /usr/local/pf/conf/pfdetect.conf.example
%config(noreplace)      /usr/local/pf/conf/pfqueue.conf
                        /usr/local/pf/conf/pfqueue.conf.example
%config                 /usr/local/pf/conf/pfqueue.conf.defaults
%config(noreplace)      /usr/local/pf/conf/suricata_categories.txt
                        /usr/local/pf/conf/suricata_categories.txt.example
%config(noreplace)      /usr/local/pf/conf/scan.conf
                        /usr/local/pf/conf/scan.conf.example
%dir                    /usr/local/pf/conf/ssl
%dir                    /usr/local/pf/conf/systemd
%config                 /usr/local/pf/conf/systemd/*
%config(noreplace)      /usr/local/pf/conf/switches.conf
%config                 /usr/local/pf/conf/switches.conf.defaults
                        /usr/local/pf/conf/switches.conf.example
%config(noreplace)      /usr/local/pf/conf/switch_filters.conf
                        /usr/local/pf/conf/switch_filters.conf.example
%config(noreplace)      /usr/local/pf/conf/vlan_filters.conf
                        /usr/local/pf/conf/vlan_filters.conf.example
%config                 /usr/local/pf/conf/vlan_filters.conf.defaults
%config(noreplace)      /usr/local/pf/conf/haproxy.conf
                        /usr/local/pf/conf/haproxy.conf.example
%dir                    /usr/local/pf/conf/httpd.conf.d
%config                 /usr/local/pf/conf/httpd.conf.d/captive-portal-common.tt
                        /usr/local/pf/conf/httpd.conf.d/captive-portal-common.tt.example
%config                 /usr/local/pf/conf/httpd.conf.d/httpd.aaa.tt
                        /usr/local/pf/conf/httpd.conf.d/httpd.aaa.tt.example
%config                 /usr/local/pf/conf/httpd.conf.d/httpd.admin.tt
                        /usr/local/pf/conf/httpd.conf.d/httpd.admin.tt.example
%config                 /usr/local/pf/conf/httpd.conf.d/httpd.portal.tt
                        /usr/local/pf/conf/httpd.conf.d/httpd.portal.tt.example
%config                 /usr/local/pf/conf/httpd.conf.d/httpd.parking.tt
                        /usr/local/pf/conf/httpd.conf.d/httpd.parking.tt.example
%config                 /usr/local/pf/conf/httpd.conf.d/httpd.proxy.tt
                        /usr/local/pf/conf/httpd.conf.d/httpd.proxy.tt.example
%config                 /usr/local/pf/conf/httpd.conf.d/httpd.webservices.tt
                        /usr/local/pf/conf/httpd.conf.d/httpd.webservices.tt.example
%config                 /usr/local/pf/conf/httpd.conf.d/httpd.collector.tt
                        /usr/local/pf/conf/httpd.conf.d/httpd.collector.tt.example
%config                 /usr/local/pf/conf/httpd.conf.d/log.conf
%config(noreplace)	/usr/local/pf/conf/httpd.conf.d/ssl-certificates.conf
                        /usr/local/pf/conf/httpd.conf.d/ssl-certificates.conf.example
%config(noreplace)      /usr/local/pf/conf/iptables.conf
%config(noreplace)      /usr/local/pf/conf/keepalived.conf
                        /usr/local/pf/conf/keepalived.conf.example
%config(noreplace)      /usr/local/pf/conf/cluster.conf
                        /usr/local/pf/conf/cluster.conf.example
%config(noreplace)      /usr/local/pf/conf/listener.msg
                        /usr/local/pf/conf/listener.msg.example
%dir                    /usr/local/pf/conf/caddy-services
%config                 /usr/local/pf/conf/caddy-services/pfsso.conf
%config                 /usr/local/pf/conf/caddy-services/httpdispatcher.conf
%dir                    /usr/local/pf/conf/monitoring
%config(noreplace)      /usr/local/pf/conf/monitoring/netdata.conf
                        /usr/local/pf/conf/monitoring/netdata.conf.example
%config                 /usr/local/pf/conf/monitoring/*.conf
                        /usr/local/pf/conf/monitoring/*.conf.example
%config                 /usr/local/pf/conf/monitoring/charts.d/*.conf
                        /usr/local/pf/conf/monitoring/charts.d/*.conf.example
%config                 /usr/local/pf/conf/monitoring/health.d/*.conf
                        /usr/local/pf/conf/monitoring/health.d/*.conf.example
%config                 /usr/local/pf/conf/monitoring/node.d/*.md
%config                 /usr/local/pf/conf/monitoring/python.d/*.conf
                        /usr/local/pf/conf/monitoring/python.d/*.conf.example
%config                 /usr/local/pf/conf/monitoring/statsd.d/*.conf
                        /usr/local/pf/conf/monitoring/statsd.d/*.conf.example
%config(noreplace)      /usr/local/pf/conf/profiles.conf
%config                 /usr/local/pf/conf/profiles.conf.defaults
%config(noreplace)      /usr/local/pf/conf/pfmon.conf
%config                 /usr/local/pf/conf/pfmon.conf.defaults
%config(noreplace)      /usr/local/pf/conf/roles.conf
%config                 /usr/local/pf/conf/roles.conf.defaults
%config(noreplace)      /usr/local/pf/conf/snmptrapd.conf
%config(noreplace)      /usr/local/pf/conf/syslog.conf
%config                 /usr/local/pf/conf/syslog.conf.defaults
%config                 /usr/local/pf/conf/ui.conf
%config                 /usr/local/pf/conf/ui.conf.es_ES
%config(noreplace)      /usr/local/pf/conf/ui-global.conf
%config(noreplace)      /usr/local/pf/conf/violations.conf
%config                 /usr/local/pf/conf/violations.conf.defaults
%config(noreplace)      /usr/local/pf/conf/wmi.conf
                        /usr/local/pf/conf/wmi.conf.example
%config(noreplace)      /usr/local/pf/conf/report.conf
                        /usr/local/pf/conf/report.conf.defaults
                        /usr/local/pf/conf/report.conf.example
%config(noreplace)      /usr/local/pf/conf/traffic_shaping.conf
                        /usr/local/pf/conf/traffic_shaping.conf.example
%doc                    /usr/local/pf/COPYING
%dir                    /usr/local/pf/db
                        /usr/local/pf/db/*
%dir                    /usr/local/pf/docs
%dir                    /usr/local/pf/docs/enforcement
%doc                    /usr/local/pf/docs/enforcement/*
%dir                    /usr/local/pf/docs/firewall
%doc                    /usr/local/pf/docs/firewall/*
%dir                    /usr/local/pf/docs/networkdevice
%doc                    /usr/local/pf/docs/networkdevice/*
%dir                    /usr/local/pf/docs/pki
%doc                    /usr/local/pf/docs/pki/*
%dir                    /usr/local/pf/docs/provisioner
%doc                    /usr/local/pf/docs/provisioner/*
%dir                    /usr/local/pf/html/pfappserver/root/static/doc
%doc                    /usr/local/pf/html/pfappserver/root/static/doc/*
%doc                    /usr/local/pf/docs/*.asciidoc
%if %{builddoc} == 1
%doc                    /usr/local/pf/docs/*.pdf
%endif
%doc                    /usr/local/pf/docs/*.xml
%doc                    /usr/local/pf/docs/fdl-1.2.txt
%dir                    /usr/local/pf/docs/includes
%doc                    /usr/local/pf/docs/includes/*.asciidoc
%doc                    /usr/local/pf/docs/pfcmd.help
%dir                    /usr/local/pf/html
%dir                    /usr/local/pf/html/captive-portal
                        /usr/local/pf/html/captive-portal/Changes
                        /usr/local/pf/html/captive-portal/Makefile.PL
                        /usr/local/pf/html/captive-portal/README
%config(noreplace)      /usr/local/pf/html/captive-portal/captiveportal.conf
                        /usr/local/pf/html/captive-portal/captiveportal.conf.example
%config(noreplace)      /usr/local/pf/html/common/styles.css
%config(noreplace)      /usr/local/pf/html/common/styles.css.map
%config(noreplace)      /usr/local/pf/html/common/styles-dark.css
                        /usr/local/pf/html/captive-portal/content/countdown.min.js
                        /usr/local/pf/html/captive-portal/content/guest-management.js
                        /usr/local/pf/html/common/Gruntfile.js
                        /usr/local/pf/html/captive-portal/content/captiveportal.js
                        /usr/local/pf/html/common/package.json
                        /usr/local/pf/html/captive-portal/content/timerbar.js
                        /usr/local/pf/html/captive-portal/content/ChilliLibrary.js
                        /usr/local/pf/html/captive-portal/content/shared_mdm_profile.mobileconfig
                        /usr/local/pf/html/captive-portal/content/packetfence-windows-agent.exe
                        /usr/local/pf/html/captive-portal/content/billing/stripe.js
                        /usr/local/pf/html/captive-portal/content/provisioner/mobileconfig.js
                        /usr/local/pf/html/captive-portal/content/provisioner/sepm.js
                        /usr/local/pf/html/captive-portal/content/release.js
                        /usr/local/pf/html/captive-portal/content/scan.js
                        /usr/local/pf/html/captive-portal/content/status.js
                        /usr/local/pf/html/captive-portal/content/waiting.js
%dir                    /usr/local/pf/html/captive-portal/content/images
                        /usr/local/pf/html/captive-portal/content/images/*
%config(noreplace)      /usr/local/pf/html/common/scss/*.scss
%dir                    /usr/local/pf/html/captive-portal/lib

                        /usr/local/pf/html/captive-portal/lib/*
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Controller/Activate/Email.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Controller/Authenticate.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Controller/DeviceRegistration.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Controller/Enabler.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Controller/Node/Manager.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Controller/Redirect.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Controller/Remediation.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Controller/Root.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Controller/Status.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Controller/WirelessProfile.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Form/Authentication.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Form/Field/AUP.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Form/Widget/Field/AUP.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/Model/Portal/Session.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/View/HTML.pm
%config(noreplace)      /usr/local/pf/html/captive-portal/lib/captiveportal/View/MobileConfig.pm

%dir                    /usr/local/pf/html/captive-portal/script
                        /usr/local/pf/html/captive-portal/script/*
%dir                    /usr/local/pf/html/captive-portal/t
                        /usr/local/pf/html/captive-portal/t/*
                        /usr/local/pf/html/captive-portal/content/PacketFenceAgent.apk
%dir                    /usr/local/pf/html/captive-portal/templates
                        /usr/local/pf/html/captive-portal/templates/*
%dir                    /usr/local/pf/html/common
                        /usr/local/pf/html/common/*
                        /usr/local/pf/html/parking/back-on-network.html
                        /usr/local/pf/html/parking/cgi-bin/release.pl
                        /usr/local/pf/html/parking/index.html
                        /usr/local/pf/html/parking/max-attempts.html
                        /usr/local/pf/html/pfappserver/
%config(noreplace)      /usr/local/pf/html/pfappserver/pfappserver.conf
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Admin.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/AdminRoles.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/Firewall_SSO.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/FloatingDevice.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/Networks.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/Pf.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/Profile/Default.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/Profile.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/Provisioning.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/Realm.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/Switch.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/System.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Configuration.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Configurator.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Config/Wrix.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/DB.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Graph.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Interface.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Node.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Root.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/SavedSearch/Node.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/SavedSearch/User.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Service.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/User.pm
%config(noreplace)      /usr/local/pf/html/pfappserver/lib/pfappserver/Controller/Violation.pm
                        /usr/local/pf/lib
%exclude                /usr/local/pf/lib/pfconfig*
%config(noreplace)      /usr/local/pf/lib/pf/floatingdevice/custom.pm
%config(noreplace)      /usr/local/pf/lib/pf/inline/custom.pm
%config(noreplace)      /usr/local/pf/lib/pf/lookup/node.pm
%config(noreplace)      /usr/local/pf/lib/pf/lookup/person.pm
%dir                    /usr/local/pf/lib/pf/pfcmd
                        /usr/local/pf/lib/pf/pfcmd/*
%dir                    /usr/local/pf/lib/pf/Portal
                        /usr/local/pf/lib/pf/Portal/*
%dir                    /usr/local/pf/lib/pf/radius
                        /usr/local/pf/lib/pf/radius/constants.pm
%config(noreplace)      /usr/local/pf/lib/pf/radius/custom.pm
%config(noreplace)      /usr/local/pf/lib/pf/roles/custom.pm
%config(noreplace)      /usr/local/pf/lib/pf/role/custom.pm
%config(noreplace)      /usr/local/pf/lib/pf/web/custom.pm

%dir                    /usr/local/pf/go
                        /usr/local/pf/go/*

%dir                    /usr/local/pf/logs
# logfiles
%ghost                  %logdir/packetfence.log
%ghost                  %logdir/snmptrapd.log
%ghost                  %logdir/pfdetect
%ghost                  %logdir/pfmon
%doc                    /usr/local/pf/NEWS.asciidoc
%doc                    /usr/local/pf/NEWS.old
%doc                    /usr/local/pf/README.md
%doc                    /usr/local/pf/README.network-devices
%dir                    /usr/local/pf/sbin
%attr(0755, pf, pf)     /usr/local/pf/sbin/pfbandwidthd
%attr(0755, pf, pf)     /usr/local/pf/sbin/pfdetect
%attr(0755, pf, pf)     /usr/local/pf/sbin/pfdhcplistener
%attr(0755, pf, pf)     /usr/local/pf/sbin/pfunified_api
%attr(0755, pf, pf)     /usr/local/pf/sbin/pf-mariadb
%attr(0755, pf, pf)     /usr/local/pf/sbin/pfmon
%attr(0755, pf, pf)     /usr/local/pf/sbin/pfqueue
%attr(0755, pf, pf)     /usr/local/pf/sbin/pfsetvlan
%attr(0755, pf, pf)     /usr/local/pf/sbin/pffilter
%attr(0755, pf, pf)     /usr/local/pf/sbin/system-id
%attr(0755, pf, pf)     /usr/local/pf/sbin/winbindd-wrapper
%attr(0755, pf, pf)     /usr/local/pf/sbin/radsniff-wrapper
%doc                    /usr/local/pf/UPGRADE.asciidoc
%doc                    /usr/local/pf/UPGRADE.old
%dir                    /usr/local/pf/var
%dir                    /usr/local/pf/var/conf
%dir                    /usr/local/pf/raddb
                        /usr/local/pf/raddb/*
%config                 /usr/local/pf/raddb/clients.conf
%config                 /usr/local/pf/raddb/proxy.conf
%config                 /usr/local/pf/raddb/users
%config(noreplace)      /usr/local/pf/raddb/policy.d/*
%config(noreplace)      /usr/local/pf/raddb/mods-enabled/*
%config(noreplace)      /usr/local/pf/raddb/mods-config/*
%config(noreplace)      /usr/local/pf/raddb/mods-available/*
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/buffered-sql
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/coa
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/control-socket
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/copy-acct-to-home-server
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/decoupled-accounting
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/default
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/dhcp
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/dynamic-clients
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/example
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/inner-tunnel
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/originate-coa
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/proxy-inner-tunnel
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/robust-proxy-accounting
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/status
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/virtual.example.com
%attr(0755, pf, pf) %config(noreplace)    /usr/local/pf/raddb/sites-available/vmps
%dir                    /usr/local/pf/var/run
%dir                    /usr/local/pf/var/rrd
%dir                    /usr/local/pf/var/session
%dir                    /usr/local/pf/var/webadmin_cache
%dir                    /usr/local/pf/var/control
%dir                    /usr/local/pf/var/redis_cache
%dir                    /usr/local/pf/var/redis_queue
%dir                    /usr/local/pf/var/redis_ntlm_cache
%dir                    /usr/local/pf/var/ssl_mutex
%config(noreplace)      /usr/local/pf/var/cache_control

# Remote arp sensor file list
%files -n %{real_name}-remote-arp-sensor
%defattr(-, pf, pf)
%dir                    /usr/local/pf
%dir                    /usr/local/pf/conf
%config(noreplace)      /usr/local/pf/conf/pfarp_remote.conf
%dir                    /usr/local/pf/sbin
%attr(0755, pf, pf)     /usr/local/pf/sbin/pfarp_remote
%dir                    /usr/local/pf/var
%dir                    /usr/local/pf/var/run

%files -n %{real_name}-pfcmd-suid
%attr(6755, root, root) /usr/local/pf/bin/pfcmd

%files -n %{real_name}-ntlm-wrapper
%attr(0755, root, root) /usr/local/pf/bin/ntlm_auth_wrapper

%files -n %{real_name}-config
%defattr(-, pf, pf)
%attr(0644, root, root) /usr/lib/systemd/system/packetfence-config.service
%dir                    /usr/local/pf
%dir %attr(0770, pf pf) /usr/local/pf/conf
%config(noreplace)      /usr/local/pf/conf/pfconfig.conf
%dir                    /usr/local/pf/lib
%dir                    /usr/local/pf/lib/pfconfig
                        /usr/local/pf/lib/pfconfig/*
%attr(0755, pf, pf)     /usr/local/pf/sbin/pfconfig
%dir                    /usr/local/pf/addons/pfconfig
%exclude                /usr/local/pf/addons/pfconfig/pfconfig.init

%changelog
