ipv4.prefixes: data/amer data/emea data/bogon china_non-apac.prefixes
	ruby ./bin/compile -r data/amer,data/emea -n data/bogon,china_non-apac.prefixes > ipv4.prefixes

china.prefixes:
	wget https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt -O china.prefixes

china_non-apac.prefixes: china.prefixes
	ruby ./bin/compile -r china.prefixes -n data/apac > china_non-apac.prefixes

china.ipv4.patterns: china.ipv4.prefixes apac.ipv4.patterns
	echo 'begin' > /tmp/china.ipv4.query
	grep -v china.ipv4.prefixes -f apac.ipv4.patterns >> /tmp/china.ipv4.query
	echo 'end' >> /tmp/china.ipv4.query
	netcat v4.whois.cymru.com 43 < /tmp/china.ipv4.query | sort -n | grep ', CN' \
		| cut -d '|' -f 2 | sed 's/[ \t]//g' > china.ipv4.patterns

exceptions.ipv4.prefixes: bogon.ipv4.prefixes china_non-apnic.ipv4.prefixes
	cat bogon.ipv4.prefixes china_non-apnic.ipv4.prefixes noroute.ipv4.prefixes \
		| grep -v -f exceptions.ipv4.ignore > exceptions.ipv4.prefixes

clean:
	rm -rf *.prefixes

.PHONY: clean
