# hosts :archivo con ips, dominios. Esto pude cambiar a una variable
# timeout :  el tiempo de conexion maximo.
# Se creo el script para ver el tema regreSSHion, se puede utilizar para enumerar que version tienen los hosts de ssh.
# RegreSSHion Version Logic:
# Menor a 4.4p1 (Excluyendo) es vulnerable , dentro de 4.4p1 y 8.4 no es vulnerable, 8.4p1 para arriba es vulnerable.
timeout=10; hosts="hosts.txt"; check_vulnerability() { local line="$1"; local version=$(echo "$line" | grep -oP 'OpenSSH_\K[\d\.]+'); if [[ -z "$version" ]]; then echo "No se pudo determinar la versión de OpenSSH en la línea proporcionada: $line"; return; fi; echo "Versión: $version"; echo "Banner: $line";}; [ ! -f "$hosts_file" ] && echo "El archivo $hosts_file no existe o no es accesible." && exit 1; while IFS= read -r host || [[ -n "$host" ]]; do echo "Host: $host"; ssh_version=$(echo "SSH-2.0-" | nc -w "$timeout" "$host" 22 | grep "SSH-" | head -n 1 | cut -d' ' -f2-); if [[ -n "$ssh_version" ]]; then check_vulnerability "$ssh_version"; else echo "No se pudo obtener la versión de SSH en $host dentro del tiempo especificado ($timeout segundos)"; fi; echo ""; done < "$hosts_file"
