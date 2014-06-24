#!/usr/bin/perl

$com = <STDIN>;
exec "perl /root/bk.pl ".$com;

# $com debe de contener: ip_maquina cod_cliente cod_maquina manual usuario_ftp pass_ftp