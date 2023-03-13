#!/bin/bash
#
########################################################################################################################
########################################################################################################################
#	Autor ..................................................: Anderson Lopez                                           #
#	Site ...................................................: www.corp.com.br                                          #
#	Data ...................................................: 18/02/2023                                               #
#	Data atualização .......................................: 19/02/2023                                               #
#	Versão .................................................: 0.04                                                     #
########################################################################################################################
########################################################################################################################
#
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
#
# Parâmetros (variáveis de ambiente) utilizados nos scripts de instalação dos Serviços de Rede
# no Ubuntu Server 20.04.x LTS.
#
########################################################################################################################
#                                   VARIÁVEIS GLOBAIS UTILIZADAS EM TODOS OS SCRIPTS                                   #
########################################################################################################################
#
# Declarando as variáveis utilizadas na verificação e validação da versão do Ubuntu Server 
#
# Variável da Hora Inicial do Script, utilizada para calcular o tempo de execução do script
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário é "Root" e versão do "Ubuntu"
# opções do comando id: -u (user)
# opções do comando: lsb_release: -r (release), -s (short), 
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
#
# Variável do Caminho e Nome do arquivo de Log utilizado em todos os script
# opção da variável de ambiente $0: Nome do comando/script executado
# opção do redirecionador | (piper): Conecta a saída padrão com a entrada padrão de outro comando
# opções do comando cut: -d (delimiter), -f (fields)
LOGSCRIPT="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração e
# nenhuma interação durante a instalação ou atualização do sistema via Apt ou Apt-Get. Ele 
# aceita a resposta padrão para todas as perguntas.
export DEBIAN_FRONTEND="noninteractive"
#
########################################################################################################################
#                             VARIÁVEIS DE REDE DO SERVIDOR UTILIZADAS EM TODOS OS SCRIPTS                             #
########################################################################################################################
#
# Declarando as variáveis utilizadas nas configurações de Rede do Servidor Ubuntu.
USUARIODEFAULT="admin"
#
# OBSERVAÇÃO IMPORTANTE: essa variável será utilizada em outras variáveis desse curso
SENHADEFAULT="@q1w2e3r4"
#
NOMESERVER="srvsp01ws01"
#
# OBSERVAÇÃO IMPORTANTE: essa variável será utilizada em outras variáveis desse curso
DOMINIOSERVER="ti.corp"
#
# OBSERVAÇÃO IMPORTANTE: essa variável será utilizada em outras variáveis desse curso
# opção do redirecionador | (piper): Conecta a saída padrão com a entrada padrão de outro comando
# opções do comando cut: -d (delimiter), -f (fields)
DOMINIONETBIOS="$(echo $DOMINIOSERVER | cut -d'.' -f1)"
#
# Variável do Nome (Hostname) FQDN (Fully Qualified Domain Name)
# OBSERVAÇÃO IMPORTANTE: essa variável será utilizada em outras variáveis desse curso
FQDNSERVER="$NOMESERVER.$DOMINIOSERVER"
#
# Variável do Endereço IPv4 principal (padrão)
IPV4SERVER="182.13.1.10"
#
# CUIDADO!!! o nome da interface de rede pode mudar dependendo da instalação do Ubuntu Server,
# verificar o nome da interface com o comando: ip address show e mudar a variável INTERFACE com
# o nome correspondente.
INTERFACE="eth0"
#
# CUIDADO!!! o nome do arquivo de configuração da placa de rede pode mudar dependendo da 
# versão do Ubuntu Server, verificar o conteúdo do diretório: /etc/netplan para saber o nome 
# do arquivo de configuração do Netplan e mudar a variável NETPLAN com o nome correspondente.
NETPLAN="/etc/netplan/00-installer-config.yaml"
#
########################################################################################################################
#                                     VARIÁVEIS UTILIZADAS NO SCRIPT: 01_openssh.sh                                    #
########################################################################################################################
#
# Arquivos de configuração (conf) do Serviço de Rede OpenSSH utilizados nesse script
# 01. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
# 02. /etc/hostname = arquivo de configuração do Nome FQDN do Servidor
# 03. /etc/hosts = arquivo de configuração da pesquisa estática para nomes de host local
# 04. /etc/nsswitch.conf = arquivo de configuração do switch de serviço de nomes de serviço
# 05. /etc/ssh/sshd_config = arquivo de configuração do Servidor OpenSSH
# 06. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço de rede
# 07. /etc/hosts.deny = arquivo de configuração de negação de hosts por serviço de rede
# 08. /etc/issue.net = arquivo de configuração do Banner utilizado pelo OpenSSH no login
# 09. /etc/default/shellinabox = arquivo de configuração da aplicação Shell-In-a-Box
# 10. /etc/neofetch/config.conf = arquivo de configuração da aplicação Neofetch
# 11. /etc/cron.d/neofetch-cron = arquivo de atualização do Banner Motd o Neofetch
# 12. /etc/motd = arquivo de mensagem do dia gerado pelo Neofetch utilizando o CRON
# 13. /etc/rsyslog.d/50-default.conf = arquivo de configuração do Syslog/Rsyslog
#
# Arquivos de monitoramento (log) do Serviço de Rede OpenSSH Server utilizados nesse script
# 01. systemctl status ssh = status do serviço do OpenSSH
# 02. journalctl -t sshd = todas as mensagens referente ao serviço do OpenSSH
# 03. tail -f /var/log/syslog | grep sshd = filtrando as mensagens do serviço do OpenSSH
# 04. tail -f /var/log/auth.log | grep ssh = filtrando as mensagens de autenticação do OpenSSH
# 05. tail -f /var/log/tcpwrappers-allow-ssh.log = filtrando as conexões permitidas do OpenSSH
# 06. tail -f /var/log/tcpwrappers-deny.log = filtrando as conexões negadas do OpenSSH
# 07. tail -f /var/log/cron.log = filtrando as mensagens do serviço do CRON
#
########################################################################################################################
# Variável das dependências do laço de loop do OpenSSH Server
SSHDEP="openssh-server openssh-client"
#
########################################################################################################################
# Variável de instalação dos softwares extras do OpenSSH Server
SSHINSTALL="net-tools traceroute ipcalc nmap tree pwgen neofetch"
#
########################################################################################################################
# Variável da porta de conexão padrão do OpenSSH Server
PORTSSH="22"
#
########################################################################################################################
#                                      VARIÁVEIS UTILIZADAS NO SCRIPT: 02_dhcp.sh                                      #
########################################################################################################################
#
# Arquivos de configuração (conf) do Serviço de Rede ISC DHCP Sever utilizados nesse script
# 01. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 02. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
# 03. /etc/default/isc-dhcp-server = arquivo de configuração do serviço do ISC DHCP Server
#
# Arquivos de monitoramento (log) do Serviço de Rede ISC DHCP Server utilizados nesse script
# 01. systemctl status isc-dhcp-server = status do serviço do ISC DHCP
# 02. journalctl -t dhcpd = todas as mensagens referente ao serviço do ISC DHCP
# 03. tail -f /var/log/syslog | grep dhcpd = filtrando as mensagens do serviço do ISC DHCP
# 04. tail -f /var/log/dmesg | grep dhcpd = filtrando as mensagens de erros do ISC DHCP
# 05. less /var/lib/dhcp/dhcpd.leases = filtrando os alugueis de endereços IPv4 do ISC DHCP
# 06. dhcp-lease-list = comando utilizado para mostrar os leases dos endereços IPv4 do ISC DHCP
# 07. tcpdump -vv -n -i enp0s3 port bootps or port bootpc = dump dos pacotes do ISC DHCP
#
########################################################################################################################
# Variável de instalação do serviço de rede ISC DHCP Server
DHCPINSTALL="isc-dhcp-server net-tools"
#
########################################################################################################################
# Variável de download do arquivo do IEEE OUI (Organizationally Unique Identifier)
OUI="https://standards-oui.ieee.org/oui/oui.txt"
#
########################################################################################################################
# Variável da porta de conexão padrão do ISC DHCP Server
PORTDHCP="67"
#
########################################################################################################################
#                                      VARIÁVEIS UTILIZADAS NO SCRIPT: 03_dns.sh                                       #
########################################################################################################################
#
# Arquivos de configuração (conf) do Serviço de Rede BIND DNS Server utilizados nesse script
# 01. /etc/hostname = arquivo de configuração do Nome FQDN do Servidor
# 02. /etc/hosts = arquivo de configuração da pesquisa estática para nomes de host local
# 03. /etc/nsswitch.conf = arquivo de configuração do switch de serviço de nomes
# 04. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
# 05. /etc/bind/named.conf = arquivo de configuração da localização dos Confs do Bind9
# 06. /etc/bind/named.conf.local = arquivo de configuração das Zonas do Bind9
# 07. /etc/bind/named.conf.options = arquivo de configuração do Serviço do Bind9
# 08. /etc/bind/named.conf.default-zones = arquivo de configuração das Zonas Padrão do Bind9
# 09. /etc/bind/rndc.key = arquivo de configuração das Chaves RNDC de integração Bind9 e DHCP
# 10. /var/lib/bind/.corp.hosts = arquivo de configuração da Zona de Pesquisa Direta
# 11. /var/lib/bind/182.13.1.rev = arquivo de configuração da Zona de Pesquisa Reversas
# 12. /etc/default/named = arquivo de configuração do Daemon do Serviço do Bind9
# 13. /etc/cron.d/dnsupdate-cron = arquivo de configuração das atualizações de Ponteiros
# 14. /etc/cron.d/rndcupdate-cron = arquivo de configuração das atualizações das Estatísticas
# 15. /etc/logrotate.d/rndcstats = arquivo de configuração do Logrotate das Estatísticas
#
# Arquivos de monitoramento (log) do Serviço de Rede Bind DNS Server utilizados nesse script
# 01. systemctl status bind9 = status do serviço do Bind DNS
# 02. journalctl -t named = todas as mensagens referente ao serviço do Bind DNS
# 03. tail -f /var/log/syslog | grep named = filtrando as mensagens do serviço do Bind DNS
# 04. tail -f /var/log/named/* = vários arquivos de Log's dos serviços do Bind DNS
# 05. tail -f /var/log/cron.log = filtrando as mensagens do serviço do CRON
#
# Declarando as variáveis de Pesquisa Direta do Domínio, Reversa e Subrede do Bind DNS Server
#
########################################################################################################################
# Variável do nome do Domínio do Servidor DNS (veja a linha: 64 desse arquivo)
DOMAIN=$DOMINIOSERVER
#
########################################################################################################################
# Variável do nome da Pesquisa Reversa do Servidor de DNS
DOMAINREV="1.13.182.in-addr.arpa"
#
########################################################################################################################
# Variável do endereço IPv4 da Subrede do Servidor de DNS
NETWORK="182.13.1."
#
########################################################################################################################
# Variável de instalação do serviço de rede Bind DNS Server
DNSINSTALL="bind9 bind9utils bind9-doc dnsutils net-tools"
#
########################################################################################################################
# Variáveis das portas de conexão padrão do Bind DNS Server
PORTDNS="53"
PORTRNDC="953"
#
########################################################################################################################
#                                    VARIÁVEIS UTILIZADAS NO SCRIPT: 04_dhcpdns.sh                                     #
########################################################################################################################
#
# Arquivos de configuração (conf) da integração do Bind9 e do DHCP utilizados nesse script
# 01. tsig.key - arquivo de geração da chave TSIG de integração do Bind9 e do DHCP
# 02. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 03. /etc/bind/named.conf.local = arquivo de configuração das Zonas do Bind9
# 04. /etc/bind/rndc.key = arquivo de configuração das Chaves RNDC de integração Bind9 e DHCP
#
# Arquivos de monitoramento (log) dos Serviços de Rede Bind9 e do DHCP utilizados nesse script
# 01. dhcp-lease-list = comando utilizado para mostrar os leases dos endereços IPv4 do ISC DHCP
# 02. less /var/lib/bind/.corp.hosts = arquivo de configuração da Zona de Pesquisa Direta
# 03. less /var/lib/bind/182.13.1.rev = arquivo de configuração da Zona de Pesquisa Reversas
#
# Declarando a variável de geração da chave de atualização dos registros do Bind DNS Server 
# integrado no ISC DHCP Server
#
########################################################################################################################
# Variável da senha em modo texto que está configurada nos arquivos: dhcpd.conf, named.conf.local
# e rndc.key que será substituída pela nova chave criptografada da variável: USERUPDATE
SECRETUPDATE="admin"
#
########################################################################################################################
# Variável da senha utilizada na criação da chave de atualização dos ponteiros do DNS e DHCP
USERUPDATE="admin"
#
########################################################################################################################
# Variável das dependências do laço de loop da integração do Bind DNS e do ISC DHCP Server
DHCPDNSDEP="isc-dhcp-server bind9"
#