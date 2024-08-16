#!/bin/bash

# Función para deshabilitar IPv6
disable_ipv6() {
    echo "Deshabilitando IPv6..."

    # Deshabilitar IPv6 en sysctl
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
    sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

    # Persistir cambios en la configuración de sysctl
    echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/99-disable-ipv6.conf

    # Aplicar cambios de sysctl
    sudo sysctl --system

    # Deshabilitar IPv6 en GRUB (opcional)
    if grep -q "GRUB_CMDLINE_LINUX" /etc/default/grub; then
        sudo sed -i 's/GRUB_CMDLINE_LINUX="/&ipv6.disable=1 /' /etc/default/grub
        sudo update-grub
    fi

    # Deshabilitar IPv6 en interfaces de red (opcional)
    for iface in $(ls /sys/class/net/); do
        sudo ip link set dev "$iface" type dummy
    done

    echo "IPv6 ha sido deshabilitado."
}

# Función para verificar si IPv6 está deshabilitado
check_ipv6_status() {
    echo "Verificando el estado de IPv6..."

    # Verificar configuraciones de sysctl
    local ipv6_disabled=$(sysctl net.ipv6.conf.all.disable_ipv6 | grep -o '1$')
    if [ "$ipv6_disabled" == "1" ]; then
        echo "IPv6 está deshabilitado en la configuración de sysctl."
    else
        echo "IPv6 aún está habilitado en la configuración de sysctl."
    fi

    # Verificar si hay direcciones IPv6 presentes
    if ! ip -6 addr show | grep -q "inet6"; then
        echo "No se encontraron direcciones IPv6. Es probable que IPv6 esté deshabilitado."
    else
        echo "Se encontraron direcciones IPv6. IPv6 podría seguir habilitado."
    fi
}

# Ejecución principal del script
disable_ipv6
check_ipv6_status
