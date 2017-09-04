ipv4.prefixes: data/amer data/emea data/bogon data/china
	ruby ./bin/compile -r data/amer,data/emea -n data/bogon,data/china > ipv4.prefixes

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
		| grep -v -f exceptions.ipv4.ignore > exceptions.ipv4.prefixes

clean:
	rm -rf *.prefixes

.PHONY: clean
