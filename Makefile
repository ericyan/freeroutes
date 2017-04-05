ipv4.prefixes: amer.ipv4.prefixes emea.ipv4.prefixes exceptions.ipv4.prefixes
	cat amer.ipv4.prefixes emea.ipv4.prefixes | aggregate > ipv4.prefixes

amer.ipv4.prefixes: ipv4-address-space.csv
	grep -e whois.arin.net -e whois.lacnic.net ipv4-address-space.csv | cut -d ',' -f 1 \
		| sed 's/^0*//' | sed 's/\/8/\.0\.0\.0\/8/' > amer.ipv4.prefixes

emea.ipv4.prefixes: ipv4-address-space.csv
	grep -e whois.ripe.net -e whois.afrinic.net ipv4-address-space.csv | cut -d ',' -f 1 \
		| sed 's/^0*//' | sed 's/\/8/\.0\.0\.0\/8/' > emea.ipv4.prefixes

apac.ipv4.prefixes: ipv4-address-space.csv
	grep -e whois.apnic.net ipv4-address-space.csv | cut -d ',' -f 1 \
		| sed 's/^0*//' | sed 's/\/8/\.0\.0\.0\/8/' > apac.ipv4.prefixes

ipv4-address-space.csv:
	wget https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv

bogon.ipv4.prefixes:
	wget https://www.team-cymru.org/Services/Bogons/bogon-bn-nonagg.txt -O bogon.ipv4.prefixes

china.ipv4.prefixes:
	wget https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt -O china.ipv4.prefixes

apac.ipv4.patterns: apac.ipv4.prefixes
	cut -d '.' -f 1 apac.ipv4.prefixes | sed 's/.*/\^&\\./' > apac.ipv4.patterns

china.ipv4.patterns: china.ipv4.prefixes apac.ipv4.patterns
	echo 'begin' > /tmp/china.ipv4.query
	grep -v china.ipv4.prefixes -f apac.ipv4.patterns >> /tmp/china.ipv4.query
	echo 'end' >> /tmp/china.ipv4.query
	netcat v4.whois.cymru.com 43 < /tmp/china.ipv4.query | sort -n | grep ', CN' \
		| cut -d '|' -f 2 | sed 's/[ \t]//g' > china.ipv4.patterns

china_non-apnic.ipv4.prefixes: china.ipv4.patterns
	grep china.ipv4.prefixes -f china.ipv4.patterns > china_non-apnic.ipv4.prefixes

exceptions.ipv4.prefixes: bogon.ipv4.prefixes china_non-apnic.ipv4.prefixes
	cat bogon.ipv4.prefixes china_non-apnic.ipv4.prefixes noroute.ipv4.prefixes \
		| aggregate > exceptions.ipv4.prefixes

clean:
	rm -rf ipv4-address-space.csv *.prefixes *.patterns

.PHONY: clean
