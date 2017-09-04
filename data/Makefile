ipv4-address-space.csv:
	wget https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv

amer: ipv4-address-space.csv
	grep -e whois.arin.net -e whois.lacnic.net ipv4-address-space.csv | cut -d ',' -f 1 \
		| sed 's/^0*//' | sed 's/\/8/\.0\.0\.0\/8/' > amer

emea: ipv4-address-space.csv
	grep -e whois.ripe.net -e whois.afrinic.net ipv4-address-space.csv | cut -d ',' -f 1 \
		| sed 's/^0*//' | sed 's/\/8/\.0\.0\.0\/8/' > emea

apac: ipv4-address-space.csv
	grep -e whois.apnic.net ipv4-address-space.csv | cut -d ',' -f 1 \
		| sed 's/^0*//' | sed 's/\/8/\.0\.0\.0\/8/' > apac

bogon:
	wget https://www.team-cymru.org/Services/Bogons/bogon-bn-nonagg.txt -O bogon

clean:
	rm -rf *

.PHONY: clean
